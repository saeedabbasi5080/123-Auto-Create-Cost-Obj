pageextension 50609 InventorySetupPageExt extends "Inventory Setup"
{
    layout
    {
        addafter(General) // Or another suitable anchor
        {
            group(Automation)
            {
                Caption = 'Automation Settings';
                field("Automatic Assign Cost Object"; Rec."Automatic Assign Cost Object")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the Cost Object dimension should be automatically assigned to items based on the Manufacturer Code.';
                }
            }
        }
    }
}