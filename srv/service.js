const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

  const { Products, Orders, OrderItems } = this.entities;

  // Computed fields: stockStatus + criticality
  this.after('GET', Products, (data) => {
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


  this.before('SAVE', Orders, async (req) => {
    if (req.data.status === 'A' || req.data.status === 'R') return;

    const items = req.data.items || [];
    if (!items.length) return;
    // Calculate total and validate product stock before save
    let total = 0;

    for (const item of items) {
      total += (item.quantity || 0) * (item.price || 0);


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

    req.data.totalAmount = total;
    req.data.status = 'N'

  });

  this.after('READ', 'Orders', (data) => {
    const orders = Array.isArray(data) ? data : [data];

    orders.forEach(o => {
      if (o.status === 'N') o.statusCriticality = 2; // Yellow - New
      else if (o.status === 'A') o.statusCriticality = 3; // Green  - Approved
      else if (o.status === 'R') o.statusCriticality = 1; // Red    - Rejected
      else if (o.status === 'P') o.statusCriticality = 2; // Yellow - Processing
      else if (o.status === 'C') o.statusCriticality = 3; // Green  - Completed
      else o.statusCriticality = 0; // Grey   - Unknown
    });
  });

  this.before(['UPDATE', 'DELETE'], Orders, async (req) => {
    const order = await SELECT.one.from(Orders).where({ ID: req.data.ID });
    if (order?.status === 'A' || order?.status === 'R')
      return req.error('Cannot edit a closed order');
  });

  this.after('READ', 'Customers', async (data) => {
    const customers = Array.isArray(data) ? data : [data];
    for (const c of customers) {
      const result = await SELECT.one
        .from('Orders')
        .columns('count(*) as count')
        .where({ customer_ID: c.ID });
      c.orderCount = result?.count || 0;
    }
  });

  this.after('PATCH', OrderItems.drafts, async (req) => {
    const item = await SELECT.one.from(OrderItems.drafts).where({ ID: req?.ID })
    const product = await SELECT.one.from(Products).where({ ID: item?.product_ID })
    const { quantity } = req

    if (item && product && quantity) {
      await UPDATE(OrderItems.drafts)
        .set({ price: product.price * quantity })
        .where({ ID: req.ID });
    }
  });


  //ACTIONS

  // Approve Order
  this.on('approveOrder', 'Orders', async (req) => {
    const orderID = req.params[0].ID;

    const order = await SELECT.one.from(Orders).where({ ID: orderID });

    if (!order) return req.error('Order not found')

    if (order.status === 'A') {
      return req.error('Order already approved');
    }

    if (order.status === 'R')
      return req.error('Cannot approve a rejected order');

    const items = await SELECT.from(OrderItems).where({
      order_ID: orderID
    });

    for (const item of items) {
      const product = await SELECT.one.from(Products).where({
        ID: item.product_ID
      });

      // Validate stock again
      if (product.stock < item.quantity) {
        return req.error(`Insufficient stock for ${product.name}`);
      }

      // Reduce stock
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

    await UPDATE(Orders)
      .set({ status: 'R' })
      .where({ ID: orderID });

    return SELECT.one.from('Orders').where({ ID: orderID });
  });

  // Complete Order
  this.on('completeOrder', 'Orders', async (req) => {
    const orderID = req.params[0].ID;
    const order = await SELECT.one.from(Orders).where({ ID: orderID });
    if (order.status !== 'A')
      return req.error(409, 'Only approved orders can be completed');
    await UPDATE(Orders).set({ status: 'C' }).where({ ID: orderID });
    return SELECT.one.from(Orders).where({ ID: orderID });
  });

  // Restock Product
  this.on('restock', 'Products', async (req) => {
    const { quantity } = req.data;
    if (!quantity || quantity <= 0)
      return req.error(400, 'Quantity must be greater than 0');
    const productID = req.params[0].ID;
    await UPDATE(Products)
      .set({ stock: { '+=': quantity } })
      .where({ ID: productID });
    return SELECT.one.from(Products).where({ ID: productID });
  });

});