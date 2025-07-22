codeunit 50620 "SalesOrderApprovalValidation"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCreateApprovalRequests', '', false, false)]
    local procedure OnBeforeCreateApprovalRequests(RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance"; var IsHandled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        DefaultDim: Record "Default Dimension";
        ItemDim: Record "Default Dimension";
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
                        // Get Cost Object from Sales Line
                        SalesLineDimValue := '';
                        DefaultDim.Reset();
                        DefaultDim.SetRange("Table ID", Database::"Sales Line");
                        DefaultDim.SetRange("No.", SalesLine."Document No.");
                        DefaultDim.SetRange("Dimension Code", CostObjectDimCode);
                        if DefaultDim.FindFirst() then
                            SalesLineDimValue := DefaultDim."Dimension Value Code";

                        // Get Cost Object from Item Card
                        ItemDimValue := '';
                        if Item.Get(SalesLine."No.") then begin
                            ItemDim.Reset();
                            ItemDim.SetRange("Table ID", Database::Item);
                            ItemDim.SetRange("No.", Item."No.");
                            ItemDim.SetRange("Dimension Code", CostObjectDimCode);
                            if ItemDim.FindFirst() then
                                ItemDimValue := ItemDim."Dimension Value Code";
                        end;

                        // Compare
                        if SalesLineDimValue <> ItemDimValue then begin
                            ErrorText := StrSubstNo('Cost Object dimension value for item %1 does not match the item card.', SalesLine."No.");
                            Error(ErrorText);
                        end;
                    end;
                until SalesLine.Next() = 0;
        end;
    end;
}