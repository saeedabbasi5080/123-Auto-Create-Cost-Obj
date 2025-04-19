tableextension 50610 ItemExtDimensions extends Item
{
    trigger OnBeforeModify()
    var
        InvSetup: Record "Inventory Setup";
        OldItem: Record Item;
        DefaultDim: Record "Default Dimension";
    begin
        InvSetup.Get();
        if not InvSetup."Automatic Assign Cost Object" then
            exit;

        OldItem.Get(Rec."No.");

        if Rec."Manufacturer Code" <> OldItem."Manufacturer Code" then begin
            // حذف Cost Object قبلی
            if OldItem."Manufacturer Code" <> '' then begin
                DefaultDim.SetRange("Table ID", Database::Item);
                DefaultDim.SetRange("No.", Rec."No.");
                DefaultDim.SetRange("Dimension Code", 'COST OBJECT');
                if DefaultDim.FindSet() then
                    DefaultDim.DeleteAll();
            end;

            // تخصیص Cost Object جدید
            if Rec."Manufacturer Code" <> '' then begin
                // کپی کردن دایمنشنهای مربوط به Manufacturer Code به آیتم
                DefaultDim.SetRange("Table ID", Database::Manufacturer);
                DefaultDim.SetRange("No.", Rec."Manufacturer Code");
                DefaultDim.SetRange("Dimension Code", 'COST OBJECT');
                DefaultDim."Dimension Value Code" := '2505';

                if DefaultDim.FindFirst() then begin
                    repeat
                        // کپی کردن دایمنشنها به آیتم
                        DefaultDim."Table ID" := Database::Item;
                        DefaultDim."No." := Rec."No.";
                        DefaultDim.Insert();
                    until DefaultDim.Next() = 0;
                end;
            end;
        end;
    end;

    trigger OnBeforeInsert()
    var
        InvSetup: Record "Inventory Setup";
        DefaultDim: Record "Default Dimension";
    begin
        InvSetup.Get();
        if InvSetup."Automatic Assign Cost Object" and (Rec."Manufacturer Code" <> '') then begin
            // تخصیص Cost Object جدید برای آیتم جدید
            DefaultDim.SetRange("Table ID", Database::Manufacturer);
            DefaultDim.SetRange("No.", Rec."Manufacturer Code");
            DefaultDim.SetRange("Dimension Code", 'COST OBJECT');

            if DefaultDim.FindFirst() then begin
                repeat
                    // کپی کردن دایمنشنها به آیتم
                    DefaultDim."Table ID" := Database::Item;
                    DefaultDim."No." := Rec."No.";
                    DefaultDim.Insert();
                until DefaultDim.Next() = 0;
            end;
        end;
    end;
}
