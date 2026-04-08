const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

  const { Products, Orders, OrderItems } = this.entities;

  /**
   * ===============================
   * 🟢 PRODUCT LOGIC
   * ===============================
   */

  // Computed fields: stockStatus + criticality
  this.after('READ', Products, (data) => {
    const rows = Array.isArray(data) ? data : [data];
    

    rows.forEach(p => {
      if (!p) return;
      const threshold = p.criticalStock ?? 5;
      if (p.stock === 0) {
        p.stockStatus = 'OUT';
        p.criticality = 1; // Red
      } else if (p.stock < threshold) {
        p.stockStatus = 'LOW';
        p.criticality = 2; // Yellow
      } else {
        p.stockStatus = 'OK';
        p.criticality = 3; // Green
      }
    });
  });

  // Prevent negative stock
  this.before(['CREATE', 'UPDATE'], Products, (req) => {
    if (req.data.stock < 0) {
      req.error('Stock cannot be negative');
    }
  });

  /**
   * ===============================
   * 🟡 ORDER ITEMS LOGIC
   * ===============================
   */

  // Auto-fetch product price
  this.before('CREATE', OrderItems, async (req) => {
    const { product_ID } = req.data;

    if (!product_ID) return;

    const product = await SELECT.one.from(Products).where({ ID: product_ID });

    if (!product) {
      req.error('Invalid product');
    }

    req.data.price = product.price;
  });

  /**
   * ===============================
   * 🔵 ORDER LOGIC
   * ===============================
   */

  // Calculate total before save
  this.before('SAVE', Orders, async (req) => {
    const items = req.data.items || [];
    if (!items.length) return;
    let total = 0;

    for (const item of items) {
      total += (item.quantity || 0) * (item.price || 0);
    }

    req.data.totalAmount = total;
  });

  // Validate stock before saving order
  this.before('SAVE', Orders, async (req) => {
    const items = req.data.items || [];

    for (const item of items) {
      const product = await SELECT.one.from(Products).where({
        ID: item.product_ID
      });

      if (!product) {
        req.error(`Product not found: ${item.product_ID}`);
      }

      if (product.stock < item.quantity) {
        req.error(`Insufficient stock for ${product.name}`);
      }
    }
  });

  /**
   * ===============================
   * 🔴 ACTIONS
   * ===============================
   */

  // Approve Order
  this.on('approveOrder', 'Orders', async (req,res) => {
    const orderID = req.params[0].ID;

    const order = await SELECT.one.from(Orders).where({ ID: orderID });

    if (!order) return 'Order not found';

    if (order.status === 'A') {
      return req.error(409,'Order already approved');
    }

    if (order.status === 'R')
    return req.error(409, 'Cannot approve a rejected order');

    const items = await SELECT.from(OrderItems).where({
      order_ID: orderID
    });

    // Validate stock again (important!)
    for (const item of items) {
      const product = await SELECT.one.from(Products).where({
        ID: item.product_ID
      });

      if (product.stock < item.quantity) {
        req.error(409, `Insufficient stock for ${product.name}`);
      }
    }

    // Reduce stock
    for (const item of items) {
      const product = await SELECT.one.from(Products).where({
        ID: item.product_ID
      });

      await UPDATE(Products)
        .set({ stock: product.stock - item.quantity })
        .where({ ID: product.ID });
    }

    // Update order status
    await UPDATE(Orders)
      .set({
        status: 'A',
        modifiedAt: new Date()
      })
      .where({ ID: orderID });

    return SELECT.one.from('Orders').where({ ID: orderID });
  });

  // Reject Order
  this.on('rejectOrder', 'Orders', async (req) => {
    const orderID = req.params[0].ID;

    const order = await SELECT.one.from('Orders').where({ ID: orderID });
    if (!order) return req.error(404, 'Order not found');

    if (order.status === 'A')
        return req.error(409, 'Cannot reject an already approved order');

    if (order.status === 'R')
        return req.error(409, 'Order is already rejected');

    await UPDATE('Orders')
        .set({ status: 'R' })
        .where({ ID: orderID });

    return SELECT.one.from('Orders').where({ ID: orderID });
});

  this.after('READ', 'Orders', (data) => {
    const orders = Array.isArray(data) ? data : [data];

    orders.forEach(o => {
        if (o.status === 'N')      o.statusCriticality = 2; // Yellow - New
        else if (o.status === 'A') o.statusCriticality = 3; // Green  - Approved
        else if (o.status === 'R') o.statusCriticality = 1; // Red    - Rejected
        else if (o.status === 'P') o.statusCriticality = 2; // Yellow - Processing
        else if (o.status === 'C') o.statusCriticality = 3; // Green  - Completed
        else                       o.statusCriticality = 0; // Grey   - Unknown
    });
});

});