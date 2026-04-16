using InventoryService as service from '../../srv/service';

annotate service.Products with @(
    UI.FieldGroup #GeneratedGroup: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: name,
            },
            {
                $Type: 'UI.DataField',
                Value: price,
            },
            {
                $Type: 'UI.DataField',
                Value: stock,
            },
            {
                $Type: 'UI.DataField',
                Value: category_code,
            },
            {
                $Type      : 'UI.DataField',
                Value      : stockStatus,
                Criticality: criticality
            },
            {
                $Type: 'UI.DataField',
                Value: criticalStock,
            },
        ],
    },
    UI.Facets                    : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Product Details',
            Target: '@UI.FieldGroup#ProductDetails'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Stock Info',
            Target: '@UI.FieldGroup#StockInfo'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Supplier',
            Target: '@UI.FieldGroup#SupplierInfo'
        }
    ],
    
    UI.FieldGroup #ProductDetails: {Data: [
        {Value: name, Label : 'Name',},
        {Value: price, Label: 'Price'},
        {Value: category_code, Label: 'Category Code'}
    ]},
    UI.FieldGroup #StockInfo     : {Data: [
        {Value: stock, Label: 'Stock'},
        {Value: criticalStock, Label: 'Critical Stock'},
        {
            Value      : stockStatus,
            Label: 'Stock Status',
            Criticality: criticality
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'service.restock',
            Label : 'Restock',
        }
    ]},
    UI.FieldGroup #SupplierInfo  : {Data: [
        { Value: supplier_ID, Label: 'Supplier ID'},
        { Value: supplier.name, Label: 'Name'},
        {Value: supplier.rating, Label: 'Rating'}
        ]},
    UI.LineItem                  : [
        {
            $Type: 'UI.DataField',
            Value: name,
            Label: 'Name'
        },
        {
            $Type: 'UI.DataField',
            Value: price,
            Label: 'Price'
        },
        {
            $Type: 'UI.DataField',
            Value: stock,
            Label: 'Stock'
        },
        {
            $Type: 'UI.DataField',
            Label: 'Category Code',
            Value: category_code,
        },
        {
            $Type      : 'UI.DataField',
            Label      : 'Stock Status',
            Value      : stockStatus,
            Criticality: criticality
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'service.restock',
            Label : 'Restock',
        },
    ],
    UI.SelectionFields           : [
        category_code,
        supplier_ID
    ],
    UI.HeaderInfo                : {
        TypeName      : 'Product',
        TypeNamePlural: 'Products',
        Title         : {Value: name},
        Description   : {Value: category_code}
    },
    UI.HeaderFacets              : [{
        $Type : 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup#Header'
    }],
    UI.FieldGroup #Header        : {Data: [
        {Value: price},
        {Value: stock},
        {
            Value      : stockStatus,
            Criticality: criticality
        }
    ]},
);

annotate service.Products with {
    supplier @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Suppliers',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: supplier_ID,
                ValueListProperty: 'ID',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'rating',
            },
        ],
    };
    supplier @Common.Text: supplier.name;
};


annotate service.Orders with @(

    UI.HeaderInfo           : {
        TypeName      : 'Order',
        TypeNamePlural: 'Orders',
        Title         : {Value: ID},
        Description   : {Value: status}
    },

    UI.SelectionFields      : [
        status,
        customer_ID
    ],

    UI.LineItem             : [
        {
            $Type: 'UI.DataField',
            Label: 'Order ID',
            Value: ID,
        },
        {
            $Type: 'UI.DataField',
            Label: 'Customer',
            Value: customer_ID,
        },
        {
            $Type      : 'UI.DataField',
            Label      : 'Status',
            Value      : status,
            Criticality: statusCriticality
        },
        {
            $Type: 'UI.DataField',
            Label: 'Total Amount',
            Value: totalAmount,
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'service.approveOrder',
            Label : 'Approve Order',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'service.completeOrder',
            Label : 'Complete Order',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'service.rejectOrder',
            Label : 'Reject Order',
        },
    ],

    UI.Facets               : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Order Info',
            Target: '@UI.FieldGroup#OrderInfo'
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Order Items',
            Target: 'items/@UI.LineItem'
        }
    ],

    UI.FieldGroup #OrderInfo: {Data: [
        {
            Value: customer_ID,
            Label: 'Customer'
        },
        {
            Value: status,
            Label: 'Status'
        },
        {
            Value: totalAmount,
            Label: 'Total Amount'
        },
        {
            Value: createdAt,
            Label: 'Created On'
        },
        {
            Value: modifiedAt,
            Label: 'Last Modified'
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'service.approveOrder',
            Label : 'Approve Order',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'service.completeOrder',
            Label : 'Complete Order',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'service.rejectOrder',
            Label : 'Reject Order',
        },
    ]},
);

annotate service.Orders with {
    customer @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Customers',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: customer_ID,
                ValueListProperty: 'ID',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name',
            },
             {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'email',
            }
        ],
        
    };
    customer @Common.Text: customer.name;
};

annotate service.OrderItems with @(UI.LineItem: [
    {
        $Type: 'UI.DataField',
        Label: 'Product',
        Value: product_ID,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Name',
        Value: product.name,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Quantity',
        Value: quantity,
    },
    {
        $Type: 'UI.DataField',
        Label: 'Unit Price',
        Value: price,
    },
]);

annotate service.OrderItems with {
 product @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Products',
        Parameters    : [
            {
                $Type            : 'Common.ValueListParameterInOut',
                LocalDataProperty: product_ID,
                ValueListProperty: 'ID',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'name',
            },
            {
                $Type            : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'price',
            },
        ],
    };
    product @Common.Text: product.name;
};

annotate service.Orders with {
    totalAmount @Common.FieldControl: #ReadOnly;
};
annotate service.OrderItems with {
    price @Common.FieldControl: #ReadOnly;
};

annotate service.Customers with @(
    UI.HeaderInfo              : {
        TypeName      : 'Customer',
        TypeNamePlural: 'Customers',
        Title         : {Value: name},
        Description   : {Value: email}
    },
    UI.LineItem                : [
        {
            Value: name,
            Label: 'Name'
        },
        {
            Value: email,
            Label: 'Email'
        },
        {
            Value: orderCount,
            Label: 'Total Orders'
        },
    ],
    UI.FieldGroup #CustomerInfo: {Data: [
        {
            Value: name,
            Label: 'Name'
        },
        {
            Value: email,
            Label: 'Email'
        },
        {
            Value: orderCount,
            Label: 'Orders Placed'
        },
    ]},
    UI.Facets                  : [{
        $Type : 'UI.ReferenceFacet',
        Label : 'Customer Info',
        Target: '@UI.FieldGroup#CustomerInfo'
    }],
);