using {inventory} from '../db/schema';

service InventoryService {

    entity Products as projection on inventory.Products {
        *
    }
        actions {
            action restock(quantity: Integer) returns Products;
        }
    entity Orders     as projection on inventory.Orders {
        *
    }
        actions {
            action approveOrder()  returns Orders;
            action rejectOrder()   returns Orders;
            action completeOrder() returns Orders;
        }

    entity OrderItems as projection on inventory.OrderItems {
        *, product
    }
    entity Customers  as projection on inventory.Customers;
    entity Suppliers  as projection on inventory.Suppliers;
    entity Categories as projection on inventory.Categories;
}

annotate InventoryService.Products with @odata.draft.enabled;
annotate InventoryService.Orders with @odata.draft.enabled;

annotate InventoryService.Orders with @Common.SideEffects: {
  TargetProperties: ['totalAmount']
};

annotate InventoryService.OrderItems with @Common.SideEffects: {
  SourceProperties: ['product_ID', 'quantity'],
  TargetProperties: ['price']
};