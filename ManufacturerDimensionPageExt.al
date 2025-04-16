pageextension 50608 "Manufacturer Card Ext" extends "Manufacturers"
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
                    Caption = 'Dimensions-&Multiple';
                    Image = DimensionSets;
                    trigger OnAction()
                    var
                        DefaultDimMultiple: Page "Default Dimensions-Multiple";
                    begin
                        DefaultDimMultiple.SetMultiRecord(Rec, Rec.FieldNo("Code"));
                        DefaultDimMultiple.RunModal();
                    end;
                }
            }
        }
    }
}