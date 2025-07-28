codeunit 50621 "Cost Object Validator"
{
    procedure ValidateSalesDocumentCostObject(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", DocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
        if SalesLine.FindSet() then
            repeat
                if SalesLine.Type = SalesLine.Type::Item then
                    ValidateLineCostObject(SalesLine."No.", SalesLine."Dimension Set ID", SalesLine.TableCaption, SalesLine."Line No.");
            until SalesLine.Next() = 0;
    end;

    procedure ValidatePurchaseDocumentCostObject(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", DocumentType);
        PurchaseLine.SetRange("Document No.", DocumentNo);
        if PurchaseLine.FindSet() then
            repeat
                if PurchaseLine.Type = PurchaseLine.Type::Item then
                    ValidateLineCostObject(PurchaseLine."No.", PurchaseLine."Dimension Set ID", PurchaseLine.TableCaption, PurchaseLine."Line No.");
            until PurchaseLine.Next() = 0;
    end;

    procedure ValidateTransferDocumentCostObject(DocumentNo: Code[20])
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", DocumentNo);
        if TransferLine.FindSet() then
            repeat
                ValidateLineCostObject(TransferLine."Item No.", TransferLine."Dimension Set ID", TransferLine.TableCaption, TransferLine."Line No.");
            until TransferLine.Next() = 0;
    end;

    procedure ValidateServiceDocumentCostObject(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
    begin
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        if ServiceLine.FindSet() then
            repeat
                if ServiceLine.Type = ServiceLine.Type::Item then
                    ValidateLineCostObject(ServiceLine."No.", ServiceLine."Dimension Set ID", ServiceLine.TableCaption, ServiceLine."Line No.");
            until ServiceLine.Next() = 0;
    end;

    procedure ValidateItemJournalCostObject(ItemJournalLine: Record "Item Journal Line")
    begin
        ValidateLineCostObject(ItemJournalLine."Item No.", ItemJournalLine."Dimension Set ID", ItemJournalLine.TableCaption, ItemJournalLine."Line No.");
    end;

    procedure ValidateRequisitionLineCostObject(RequisitionLine: Record "Requisition Line")
    begin
        if RequisitionLine.Type = RequisitionLine.Type::Item then
            ValidateLineCostObject(RequisitionLine."No.", RequisitionLine."Dimension Set ID", RequisitionLine.TableCaption, RequisitionLine."Line No.");
    end;

    local procedure ValidateLineCostObject(ItemNo: Code[20]; DimensionSetID: Integer; DocumentType: Text; LineNo: Integer)
    var
        Item: Record Item;
        ItemDim: Record "Default Dimension";
        DimSetEntry: Record "Dimension Set Entry";
        CostObjectDimCode: Code[20];
        LineDimValue: Code[20];
        ItemDimValue: Code[20];
        ErrorText: Text;
    begin
        CostObjectDimCode := 'COST OBJECT';

        // Get Cost Object from Document Line Dimension
        LineDimValue := '';
        DimSetEntry.Reset();
        DimSetEntry.SetRange("Dimension Set ID", DimensionSetID);
        DimSetEntry.SetRange("Dimension Code", CostObjectDimCode);
        if DimSetEntry.FindFirst() then
            LineDimValue := DimSetEntry."Dimension Value Code";

        // Get Cost Object from Item's Manufacturer
        ItemDimValue := '';
        if Item.Get(ItemNo) then begin
            if Item."Manufacturer Code" <> '' then begin
                ItemDim.Reset();
                ItemDim.SetRange("Table ID", Database::Manufacturer);
                ItemDim.SetRange("No.", Item."Manufacturer Code");
                ItemDim.SetRange("Dimension Code", CostObjectDimCode);
                if ItemDim.FindFirst() then
                    ItemDimValue := ItemDim."Dimension Value Code";
            end;
        end;

        // Compare and throw error if mismatch
        if LineDimValue <> ItemDimValue then begin
            ErrorText := StrSubstNo('Cost Object dimension value for item %1 does not match the item card in %2 line %3.', ItemNo, DocumentType, LineNo);
            Error(ErrorText);
        end;
    end;
}