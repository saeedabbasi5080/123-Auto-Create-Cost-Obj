codeunit 50622 "CostObjectApprovalValidation"
{
    var
        CostObjectValidator: Codeunit "Cost Object Validator";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCreateApprovalRequests', '', false, false)]
    local procedure OnBeforeCreateApprovalRequests(RecRef: RecordRef; WorkflowStepInstance: Record "Workflow Step Instance"; var IsHandled: Boolean)
    begin
        ValidateCostObjectByRecRef(RecRef);
    end;

    // Sales Events
    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnAfterCheckSalesApprovalPossible', '', false, false)]
    local procedure OnAfterCheckSalesApprovalPossible(var SalesHeader: Record "Sales Header")
    begin
        CostObjectValidator.ValidateSalesDocumentCostObject(SalesHeader."Document Type", SalesHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnBeforePrePostApprovalCheckSales', '', false, false)]
    local procedure OnBeforePrePostApprovalCheckSales(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidateSalesDocumentCostObject(SalesHeader."Document Type", SalesHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 79, 'OnBeforePostAndSend', '', false, false)]
    local procedure OnBeforePostAndSend(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var TempDocumentSendingProfile: Record "Document Sending Profile" temporary)
    begin
        CostObjectValidator.ValidateSalesDocumentCostObject(SalesHeader."Document Type", SalesHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 81, 'OnBeforeConfirmPost', '', false, false)]
    local procedure OnBeforeConfirmPost(var SalesHeader: Record "Sales Header"; var DefaultOption: Integer; var Result: Boolean; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidateSalesDocumentCostObject(SalesHeader."Document Type", SalesHeader."No.");
    end;

    // Purchase Events
    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnBeforePrePostApprovalCheckPurch', '', false, false)]
    local procedure OnBeforePrePostApprovalCheckPurch(var PurchaseHeader: Record "Purchase Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidatePurchaseDocumentCostObject(PurchaseHeader."Document Type", PurchaseHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    begin
        CostObjectValidator.ValidatePurchaseDocumentCostObject(PurchaseHeader."Document Type", PurchaseHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 91, 'OnBeforeRunPurchPost', '', false, false)]
    local procedure OnBeforeRunPurchPost91(var PurchaseHeader: Record "Purchase Header")
    begin
        CostObjectValidator.ValidatePurchaseDocumentCostObject(PurchaseHeader."Document Type", PurchaseHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 92, 'OnBeforeRunPurchPost', '', false, false)]
    local procedure OnBeforeRunPurchPost92(var PurchHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidatePurchaseDocumentCostObject(PurchHeader."Document Type", PurchHeader."No.");
    end;

    // Item Journal Events
    [EventSubscriber(ObjectType::Codeunit, 241, 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidateItemJournalCostObject(ItemJournalLine);
    end;

    // Service Events
    [EventSubscriber(ObjectType::Codeunit, 416, 'OnBeforeReleaseServiceDoc', '', false, false)]
    local procedure OnBeforeReleaseServiceDoc(var ServiceHeader: Record "Service Header")
    begin
        CostObjectValidator.ValidateServiceDocumentCostObject(ServiceHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5981, 'OnBeforePreviewDocument', '', false, false)]
    local procedure OnBeforePreviewDocument(var ServHeader: Record "Service Header"; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidateServiceDocumentCostObject(ServHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5979, 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode5979(var ServiceHeader: Record "Service Header")
    begin
        CostObjectValidator.ValidateServiceDocumentCostObject(ServiceHeader);
    end;

    // Transfer Events
    [EventSubscriber(ObjectType::Codeunit, 5706, 'OnBeforePost', '', false, false)]
    local procedure OnBeforePost(var TransHeader: Record "Transfer Header"; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidateTransferDocumentCostObject(TransHeader."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 5706, 'OnCodeOnBeforePostTransferOrder', '', false, false)]
    local procedure OnCodeOnBeforePostTransferOrder(var TransHeader: Record "Transfer Header"; var DefaultNumber: Integer; var Selection: Option; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidateTransferDocumentCostObject(TransHeader."No.");
    end;

    // Warehouse Events
    [EventSubscriber(ObjectType::Codeunit, 5760, 'OnBeforePostSourceDocument', '', false, false)]
    local procedure OnBeforePostSourceDocument(var WhseRcptLine: Record "Warehouse Receipt Line"; PurchaseHeader: Record "Purchase Header"; SalesHeader: Record "Sales Header"; TransferHeader: Record "Transfer Header"; var CounterSourceDocOK: Integer; HideValidationDialog: Boolean; var IsHandled: Boolean)
    begin
        ValidateCostObjectByHeaders(PurchaseHeader, SalesHeader, TransferHeader);
    end;

    // Requisition Events
    [EventSubscriber(ObjectType::Page, 291, 'OnBeforeCarryOutActionMsg', '', false, false)]
    local procedure OnBeforeCarryOutActionMsg(var RequisitionLine: Record "Requisition Line"; var IsHandled: Boolean)
    begin
        CostObjectValidator.ValidateRequisitionLineCostObject(RequisitionLine);
    end;

    local procedure ValidateCostObjectByRecRef(RecRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ServiceHeader: Record "Service Header";
    begin
        case RecRef.Number of
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    CostObjectValidator.ValidateSalesDocumentCostObject(SalesHeader."Document Type", SalesHeader."No.");
                end;
            Database::"Purchase Header":
                begin
                    RecRef.SetTable(PurchaseHeader);
                    CostObjectValidator.ValidatePurchaseDocumentCostObject(PurchaseHeader."Document Type", PurchaseHeader."No.");
                end;
            Database::"Transfer Header":
                begin
                    RecRef.SetTable(TransferHeader);
                    CostObjectValidator.ValidateTransferDocumentCostObject(TransferHeader."No.");
                end;
            Database::"Service Header":
                begin
                    RecRef.SetTable(ServiceHeader);
                    CostObjectValidator.ValidateServiceDocumentCostObject(ServiceHeader);
                end;
        end;
    end;

    local procedure ValidateCostObjectByHeaders(PurchaseHeader: Record "Purchase Header"; SalesHeader: Record "Sales Header"; TransferHeader: Record "Transfer Header")
    begin
        if PurchaseHeader."No." <> '' then
            CostObjectValidator.ValidatePurchaseDocumentCostObject(PurchaseHeader."Document Type", PurchaseHeader."No.");
        if SalesHeader."No." <> '' then
            CostObjectValidator.ValidateSalesDocumentCostObject(SalesHeader."Document Type", SalesHeader."No.");
        if TransferHeader."No." <> '' then
            CostObjectValidator.ValidateTransferDocumentCostObject(TransferHeader."No.");
    end;
}