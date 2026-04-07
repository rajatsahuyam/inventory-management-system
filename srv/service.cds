using {inventory} from '../db/schema';

service InventoryService @(odata.draft.enabled) {

    entity Products  as projection on inventory.Products{
        *
    };
    // entity Orders    as projection on inventory.Orders{
    //     *, items
    // };
    entity Orders    as projection on inventory.Orders actions{
        action approveOrder() returns Orders;
        action rejectOrder()  returns Orders;
    }
    entity OrderItems as projection on inventory.OrderItems;
    entity Customers as projection on inventory.Customers;
    entity Suppliers as projection on inventory.Suppliers;
    entity Categories as projection on inventory.Categories;
}
