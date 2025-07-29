#region CRID 123 - Automatic Create Cost Object Base On Brand For Items
pageextension 50609 InventorySetupPageExt extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("Automatic Assign Cost Object"; Rec."Automatic Assign Cost Object")
            {
                Caption = 'Automatic Assign Cost Object To Item';
                ApplicationArea = All;
            }
        }
    }
}
#endregion CRID 123 - Automatic Create Cost Object Base On Brand For Items