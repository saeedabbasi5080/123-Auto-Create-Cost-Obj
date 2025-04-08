tableextension 50609 InventorySetupTblExt extends "Inventory Setup"
{
    fields
    {
        field(50100; "Automatic Assign Cost Object"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Automatic Assign Cost Object To Item';
            InitValue = false;
        }
    }
}