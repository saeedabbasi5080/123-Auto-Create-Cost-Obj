#region CRID 123 - Automatic Create Cost Object Base On Brand For Items
pageextension 50608 "Manufacturer Page Ext" extends "Manufacturers"
{
    actions
    {
        addlast(Processing)
        {
            group(DimensionsGroup)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                action(DimensionSingleAction)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimension-Single';
                    Image = Dimensions;
                    RunObject = page "Default Dimensions";
                    RunPageLink = "Table ID" = const(5720), "No." = field(Name);
                }
                action(DimensionMultipleAction)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions-Multiple';
                    Image = DimensionSets;
                    trigger OnAction()
                    var
                        DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        Manufacturer: Record Manufacturer;
                    begin
                        CurrPage.SetSelectionFilter(Manufacturer);
                        DefaultDimMultiple.SetMultiRecord(Manufacturer, Manufacturer.FieldNo("Code"));
                        DefaultDimMultiple.RunModal();
                    end;
                }
            }
        }
    }
}
#endregion CRID 123 - Automatic Create Cost Object Base On Brand For Items