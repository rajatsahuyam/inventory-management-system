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
                Label: 'category_code',
                Value: category_code,
            },
            {
                $Type      : 'UI.DataField',
                Label      : 'stockStatus',
                Value      : stockStatus,
                Criticality: criticality
            },
            {
                $Type: 'UI.DataField',
                Label: 'criticalStock',
                Value: criticalStock,
            },
        ],
    },
    UI.Facets                    : [
        // {
        //     $Type : 'UI.ReferenceFacet',
        //     ID : 'GeneratedFacet1',
        //     Label : 'General Information',
        //     Target : '@UI.FieldGroup#GeneratedGroup',
        // },
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
        {Value: name},
        {Value: price},
        {Value: category_code}
    ]},
    UI.FieldGroup #StockInfo     : {Data: [
        {Value: stock},
        {Value: criticalStock},
        {
            Value      : stockStatus,
            Criticality: criticality
        }
    ]},
    UI.FieldGroup #SupplierInfo  : {Data: [{Value: supplier_ID}]},
    UI.LineItem                  : [
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
            Label: 'category_code',
            Value: category_code,
        },
        {
            $Type      : 'UI.DataField',
            Label      : 'stockStatus',
            Value      : stockStatus,
            Criticality: criticality
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
        Description   : {Value: stockStatus}
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
    }
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
            Criticality: statusCriticality // we'll add this virtual field
        },
        {
            $Type: 'UI.DataField',
            Label: 'Total Amount',
            Value: totalAmount,
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'InventoryService.approveOrder',
            Label : 'Approve Order',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'InventoryService.rejectOrder',
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
            Action: 'InventoryService.approveOrder',
            Label : 'Approve Order',
        },
        {
            $Type : 'UI.DataFieldForAction',
            Action: 'InventoryService.rejectOrder',
            Label : 'Reject Order',
        },
    ]},
);

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
