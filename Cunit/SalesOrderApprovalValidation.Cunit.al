#region 123 - Automatic Create Cost Object Base On Brand For Items
codeunit 50620 "SalesOrderApprovalValidation"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCreateApprovalRequests', '', false, false)]
    local procedure OnBeforeCreateApprovalRequests(RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance"; var IsHandled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ItemDim: Record "Default Dimension";
        DimSetEntry: Record "Dimension Set Entry"; // Added
        CostObjectDimCode: Code[20];
        SalesLineDimValue: Code[20];
        ItemDimValue: Code[20];
        ErrorText: Text[250];
    begin
        CostObjectDimCode := 'COST OBJECT';
        if RecRef.Number = Database::"Sales Header" then begin
            RecRef.SetTable(SalesHeader);
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet() then
                repeat
                    if SalesLine.Type = SalesLine.Type::Item then begin
                        // Get Cost Object from Sales Line Global Dimension 3
                        SalesLineDimValue := '';
                        DimSetEntry.Reset();
                        DimSetEntry.SetRange("Dimension Set ID", SalesLine."Dimension Set ID");
                        DimSetEntry.SetRange("Dimension Code", CostObjectDimCode);
                        if DimSetEntry.FindFirst() then
                            SalesLineDimValue := DimSetEntry."Dimension Value Code";

                        // Get Cost Object from Manufacturer of Item Card
                        ItemDimValue := '';
                        if Item.Get(SalesLine."No.") then begin
                            if Item."Manufacturer Code" <> '' then begin
                                // Finding Dimension Value Code related to Manufacturer and COST OBJECT
                                ItemDim.Reset();
                                ItemDim.SetRange("Table ID", Database::Manufacturer);
                                ItemDim.SetRange("No.", Item."Manufacturer Code");
                                ItemDim.SetRange("Dimension Code", CostObjectDimCode);
                                if ItemDim.FindFirst() then
                                    ItemDimValue := ItemDim."Dimension Value Code";
                            end;
                        end;

                        // Compare
                        if SalesLineDimValue <> ItemDimValue then begin
                            ErrorText := StrSubstNo('Cost Object dimension value for item %1 does not match the item card line %2.', SalesLine."No.", SalesLine."Line No.");
                            Error(ErrorText);
                        end;
                    end;
                until SalesLine.Next() = 0;
        end;
    end;
}
#endregion 123 - Automatic Create Cost Object Base On Brand For Items