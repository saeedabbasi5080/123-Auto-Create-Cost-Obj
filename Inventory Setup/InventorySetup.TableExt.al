#region CRID 123 - Automatic Create Cost Object Base On Brand For Items
tableextension 50609 InventorySetupTblExt extends "Inventory Setup"
{
    fields
    {
        field(50100; "Automatic Assign Cost Object"; Boolean)
        {
            Caption = 'Automatic Assign Cost Object To Item';
        }
    }
}
#endregion CRID 123 - Automatic Create Cost Object Base On Brand For Items