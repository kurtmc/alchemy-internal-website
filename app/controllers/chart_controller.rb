class ChartController < ApplicationController

    include NavisionRecord

    def main_query
        return "SELECT
    customer . No_,
    customer . \"Salesperson Code\",
    item . Description,
    ledger . \"Unit of Measure Code\",
    ledger . \"Entry Type\",
    ledger . \"External Document No_\",
    ledger . \"Invoiced Quantity\",
    ledger . \"Item Category Code\",
    ledger . \"Product Group Code\",
    ledger . \"Item No_\",
    item . \"Vendor No_\",
    item . \"Global Dimension 1 Code\",
    item . \"Global Dimension 2 Code\",
    ledger . \"Location Code\",
    ledger . \"Document Date\",
    ledger . \"Posting Date\",
    ledger . Quantity,
    value_entry . \"Item Ledger Entry Quantity\",
    ledger . \"Source No_\",
    ledger . \"Source Type\",
    value_entry . \"Sales Amount (Actual)\",
    value_entry . \"Sales Amount (Expected)\",
    value_entry . \"Cost Amount (Actual)\",
    value_entry . \"Cost Amount (Expected)\",
    value_entry . \"Cost Posted to G_L\",
    default_dim . [Dimension VALUE Code] AS \"Product Dimension\"
FROM
    #{table('Item Ledger Entry', 'NZ')} AS ledger
    JOIN #{table('Customer', 'NZ')} AS customer
        ON customer . No_ = ledger . \"Source No_\"
    JOIN #{table('Item', 'NZ')} as item
        ON item . No_ = ledger . \"Item No_\"
    JOIN #{table('Value Entry', 'NZ')} AS value_entry
        ON ledger . \"Entry No_\" = value_entry . \"Item Ledger Entry No_\"
    LEFT JOIN #{table('Default Dimension', 'NZ')} as default_dim
        ON default_dim . \"Table ID\" = 27
    AND default_dim . \"No_\" = item . No_
    AND default_dim . \"Dimension Code\" = 'PRODUCT GROUP'
WHERE
    item . No_ = ledger . \"Item No_\"
    AND customer . No_ = ledger . \"Source No_\"
    AND ledger . \"Entry No_\" = value_entry . \"Item Ledger Entry No_\"
    AND(
        (
            ledger . \"Source Type\" = 1
        )
        AND(
            ledger . \"Entry Type\" = 1
        )
    )"
    end
end
