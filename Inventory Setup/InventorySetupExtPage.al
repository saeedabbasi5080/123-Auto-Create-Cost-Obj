pageextension 50609 InventorySetupPageExt extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("Automatic Assign Cost Object"; Rec."Automatic Assign Cost Object")
            {
                Caption = 'Automation Settings';
                ApplicationArea = All;
                ToolTip = 'Specifies if the Cost Object dimension should be automatically assigned to items based on the Manufacturer Code.';
            }
        }
    }
}