SlashCmdList["nplatesreset"] = function()
    for _, v in pairs({
        "nameplateGlobalScale",
        "nameplateMinAlpha",
        "namePlateMinScale",
        "namePlateMaxScale",
        "nameplateOtherTopInset", 
        "nameplateOtherBottomInset"
    }) 
    do 
        SetCVar(v, GetCVarDefault(v)) 
    end
end
SLASH_nplatesreset1 = "/nplatesreset"