namespace inventory;

using {
  cuid,
  managed,
  sap.common.CodeList
} from '@sap/cds/common';

entity Products : cuid, managed {
  name          : String @title: 'Product Name';
  price         : Decimal(10,2) @assert.range: [0, 9999999] @title: 'Unit Price';
  stock         : Integer @assert.range: [0, 99999] @title : 'Stock';
  category      : Association to Categories;
  supplier      : Association to Suppliers;

  virtual stockStatus : String;
  virtual criticality : Integer;
  criticalStock : Integer default 5;
}

entity Categories : CodeList {
  key code : String;
}

entity Suppliers : cuid, managed {
  name      : String;
  rating    : Integer @assert.range: [1, 5];
}

entity Customers : cuid, managed {
  name      : String;
  email     : String;
}

entity Orders : cuid, managed {
  customer       : Association to Customers;

  status         : String enum {
    New        = 'N';
    Approved   = 'A';
    Rejected   = 'R';
    Completed  = 'C';
    Processing = 'P';
  };
  totalAmount    : Decimal(10,2);
  items          : Composition of many OrderItems on items.order = $self;
  virtual statusCriticality : Integer;
}

entity OrderItems: cuid {
  order       : Association to Orders;
  product     : Association to Products;
  quantity    : Integer;
  price       : Decimal(10,2);
}




