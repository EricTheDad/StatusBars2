------------------------------------------------------
-- Localization.lua
-- English strings by default, localizations override with their own.
------------------------------------------------------
--
-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad
local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally

local L =
    {
        STRING_ID_CONFIG_AURA_FILTER_ENTRY_HELP_TEXT = [=[Type the name of the buff/debuff you want to add to the list here and click the "Add Entry" button.
You must type the name exactly as it appears in the tooltip.  Capitalization is important!]=]
        ,
        STRING_ID_CONFIG_AURA_FILTER_LIST_HELP_TEXT = [=[Hides all buffs/debuffs except for the ones you add to the list below.
However, the options you checked still affect which auras are displayed.
For example, if you type in the name of a buff but don't have the
"Show Buffs" checkbox checked, the buff still won't be displayed.]=]
        
        
        ,
        STRING_ID_CONFIG_COPY_SETTINGS_TEXT = "Select a character to copy settings from",
        STRING_ID_CONFIG_LOCK_BARS_DURING_PLAY_HELP_TEXT = [=[Bars are automatically unlocked while the configuration panel is open.
Don't uncheck this unless you want to be able to move the bars while playing]=]
        ,
        STRING_ID_INTERFACEPANEL_CREDITS_TEXT_1 = "Original Addon by Wesslen",
        STRING_ID_INTERFACEPANEL_CREDITS_TEXT_2 = "Version 2 rewrite by GopherYerguns",
        STRING_ID_INTERFACEPANEL_CREDITS_TEXT_3 = "Mists of Pandaria updates by 堂吉先生 and EricTheDad",
        STRING_ID_INTERFACEPANEL_CREDITS_TEXT_4 = "Warlords of Draenor update and ongoing maintenance by EricTheDad",
        STRING_ID_INTERFACEPANEL_CREDITS_TEXT_5 = "Translations provided by:",
        STRING_ID_INTERFACEPANEL_CREDITS_TEXT_6 = [=[deDE: EricTheDad
frFR: available
itIT: available
esES: available
esMX: available
ptBR: available
ruRU: available
zhCN: available
koKR: available
zhTW: available]=]
        
        
        
        
        
        
        
        
        ,
        STRING_ID_INTERFACEPANEL_HELP_TEXT_1 = "Show this screen by typing \"/statusbars2\" or \"/sb2\" in the chat input.",
        STRING_ID_INTERFACEPANEL_HELP_TEXT_2 = "Enable configuration mode by typing in \"/statusbars2 config\" or \"/sb2 config\" or by clicking the button below.",
        STRING_ID_INTERFACEPANEL_TRANSLATORS_NEEDED = "Translators needed!  Go to http://wow.curseforge.com/addons/statusbars2/localization or message EricTheDad if you'd like to help!",
        STRING_ID_MOVE_BAR_HELP_TEXT = [=[Hold down "Alt" to move an individual bar
Hold down "Ctrl" to move a whole group
Hold down "Ctrl" + "Alt" to move all the bars at once]=]
    
    ,
    }

local addonName, addonTable = ...; -- Let's use the private table passed to every .lua file to store our locale

local function defaultFunc(L, key)
    -- If this function was called, we have no localization for this key.
    -- We could complain loudly to allow localizers to see the error of their ways,
    -- but, for now, just return the key as its own localization. This allows you to
    -- avoid writing the default localization out explicitly.
    return key;
end
setmetatable(L, {__index = defaultFunc});


addonTable.strings = L;

------------------------------------------------------
if (GetLocale() == "deDE") then
    
    -- L["Abbreviated"] = ""
    -- L["Add Entry"] = ""
    -- L["Always"] = ""
    -- L["Auto"] = ""
    -- L["Auto-layout order"] = ""
    -- L["Automatic"] = ""
    L["Available"] = "Verfügbar" -- Needs review
    -- L["Bar Options"] = ""
    -- L["Bar Select"] = ""
    -- L["Clear"] = ""
    -- L["Color"] = ""
    -- L["Combat"] = ""
    -- L["Delete Entry"] = ""
    -- L["Enable Aura Tooltips"] = ""
    -- L["Enabled"] = ""
    -- L["Enable help tooltips"] = ""
    -- L["Fade bars in and out"] = ""
    -- L["Flash when below"] = ""
    -- L["Global Options"] = ""
    -- L["Group Options"] = ""
    -- L["Hidden"] = ""
    -- L["Huge"] = ""
    -- L["Large"] = ""
    -- L["Layout Options"] = ""
    -- L["Left"] = ""
    -- L["Lock bars during play"] = ""
    -- L["Locked To Background"] = ""
    -- L["Locked To Group"] = ""
    -- L["Medium"] = ""
    -- L["Never"] = ""
    -- L["Only show auras listed"] = ""
    -- L["Only show auras with a duration"] = ""
    -- L["Only show my auras"] = ""
    -- L["Opacity"] = ""
    -- L["Percent Text"] = ""
    -- L["Reset All Group Positions"] = ""
    -- L["Right"] = ""
    -- L["Scale"] = ""
    -- L["Set Color"] = ""
    -- L["Show Buffs"] = ""
    -- L["Show Debuffs"] = ""
    -- L["Show in all forms"] = ""
    -- L["Show target spell"] = ""
    -- L["Small"] = ""
    -- L["Snap All Bars To Groups"] = ""
    -- L["StatusBars2 Config"] = ""
    -- L["STRING_ID_CONFIG_AURA_FILTER_ENTRY_HELP_TEXT"] = ""
    -- L["STRING_ID_CONFIG_AURA_FILTER_LIST_HELP_TEXT"] = ""
    -- L["STRING_ID_CONFIG_COPY_SETTINGS_TEXT"] = ""
    -- L["STRING_ID_CONFIG_LOCK_BARS_DURING_PLAY_HELP_TEXT"] = ""
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_1"] = "Ursprüngliches Addon von Wesslen" -- Needs review
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_2"] = "Version 2 Umschreibung von GopherYerguns" -- Needs review
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_3"] = "Mists of Pandaria Neufassung von 堂吉先生 und EricTheDad" -- Needs review
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_4"] = "Warlords of Draenor Neufassung und laufende Wartung von EricTheDad" -- Needs review
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_5"] = "Übersetzungen bereitgestellt von:" -- Needs review
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_6"] = [=[deDE: EricTheDad
frFR: verfügbar
itIT: verfügbar
esES: verfügbar
esMX: verfügbar
ptBR: verfügbar
ruRU: verfügbar
zhCN: verfügbar
koKR: verfügbar
zhTW: verfügbar]=]
    
    
    
    
    
    
    
    
    -- Needs review
    L["STRING_ID_INTERFACEPANEL_HELP_TEXT_1"] = "Tippe \"/statusbars2\" oder \"/sb2\" im Chat ein um dieses Fenster zu zeigen" -- Needs review
    L["STRING_ID_INTERFACEPANEL_HELP_TEXT_2"] = "Um Konfigurationsmodus zu aktivieren, tippe \"/statusbars2 config\" oder \"/sb2 config\" im Chat ein oder klicke auf die Taste hierunter." -- Needs review
    L["STRING_ID_INTERFACEPANEL_TRANSLATORS_NEEDED"] = "Übersetzer gesucht!  Geh nach http://wow.curseforge.com/addons/statusbars2/localization oder sende eine Nachricht an EricTheDad um auszuhelfen!" -- Needs review
-- L["STRING_ID_MOVE_BAR_HELP_TEXT"] = ""
-- L["Text Display Options"] = ""
-- L["Text Size"] = ""
-- L["Thousand Separators Only"] = ""
-- L["Unformatted"] = ""
end

------------------------------------------------------
if (GetLocale() == "frFR") then
    
    end

------------------------------------------------------
if (GetLocale() == "itIT") then
    
    end

------------------------------------------------------
if (GetLocale() == "esES" or GetLocale() == "esMX") then
    
    end

------------------------------------------------------
if (GetLocale() == "ptBR") then
    
    end

------------------------------------------------------
if (GetLocale() == "ruRU") then
    
    end

------------------------------------------------------
if (GetLocale() == "zhCN") then
    
    -- L["Abbreviated"] = ""
    -- L["Add Entry"] = ""
    -- L["Always"] = ""
    L["Auto"] = "当有资源值得显示时，StatusBars自动显示或隐藏。" -- Needs review
    -- L["Auto-layout order"] = ""
    -- L["Automatic"] = ""
    -- L["Available"] = ""
    -- L["Bar Options"] = ""
    -- L["Bar Select"] = ""
    -- L["Clear"] = ""
    -- L["Color"] = ""
    -- L["Combat"] = ""
    -- L["Delete Entry"] = ""
    -- L["Enable Aura Tooltips"] = ""
    -- L["Enabled"] = ""
    -- L["Enable help tooltips"] = ""
    -- L["Fade bars in and out"] = ""
    -- L["Flash when below"] = ""
    -- L["Global Options"] = ""
    -- L["Group Options"] = ""
    -- L["Hidden"] = ""
    -- L["Huge"] = ""
    -- L["Large"] = ""
    -- L["Layout Options"] = ""
    -- L["Left"] = ""
    -- L["Lock bars during play"] = ""
    -- L["Locked To Background"] = ""
    -- L["Locked To Group"] = ""
    -- L["Medium"] = ""
    -- L["Never"] = ""
    -- L["Only show auras listed"] = ""
    -- L["Only show auras with a duration"] = ""
    -- L["Only show my auras"] = ""
    -- L["Opacity"] = ""
    -- L["Percent Text"] = ""
    -- L["Reset All Group Positions"] = ""
    -- L["Right"] = ""
    -- L["Scale"] = ""
    -- L["Set Color"] = ""
    -- L["Show Buffs"] = ""
    -- L["Show Debuffs"] = ""
    -- L["Show in all forms"] = ""
    -- L["Show target spell"] = ""
    -- L["Small"] = ""
    -- L["Snap All Bars To Groups"] = ""
    -- L["StatusBars2 Config"] = ""
    -- L["STRING_ID_CONFIG_AURA_FILTER_ENTRY_HELP_TEXT"] = ""
    -- L["STRING_ID_CONFIG_AURA_FILTER_LIST_HELP_TEXT"] = ""
    -- L["STRING_ID_CONFIG_COPY_SETTINGS_TEXT"] = ""
    -- L["STRING_ID_CONFIG_LOCK_BARS_DURING_PLAY_HELP_TEXT"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_1"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_2"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_3"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_4"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_5"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_6"] = ""
    L["STRING_ID_INTERFACEPANEL_HELP_TEXT_1"] = "在聊天框中输入\"/statusbars2\"或者\"/sb2\"显示本页面。" -- Needs review
    L["STRING_ID_INTERFACEPANEL_HELP_TEXT_2"] = "输入\"/statusbars2 config\"或者\"/sb2 config\"或者点击下面的按钮开启配置模式。" -- Needs review
-- L["STRING_ID_INTERFACEPANEL_TRANSLATORS_NEEDED"] = ""
-- L["STRING_ID_MOVE_BAR_HELP_TEXT"] = ""
-- L["Text Display Options"] = ""
-- L["Text Size"] = ""
-- L["Thousand Separators Only"] = ""
-- L["Unformatted"] = ""
end

------------------------------------------------------
if (GetLocale() == "koKR") then
    L["Abbreviated"] = "천 단위 축약"
    L["Add Entry"] = "항목 추가"
    L["Always"] = "항상표시"
    L["Auto"] = "자동"
    L["Auto-layout order"] = "막대 레이아웃 순서 지정"
    L["Automatic"] = "자동화"
    --[[Translation missing --]]
    L["Available"] = "Available"
    L["Bar Options"] = "막대 설정"
    L["Bar Select"] = "막대 선택"
    L["Clear"] = "모두 삭제"
    L["Color"] = "색상"
    L["Combat"] = "전투시"
    L["Delete Entry"] = "항목 삭제"
    L["Enable Aura Tooltips"] = "오라 툴팁 활성화"
    L["Enable help tooltips"] = "도움말 툴팁 활성화"
    L["Enabled"] = "활성화"
    L["Fade bars in and out"] = "막대 서서히 사라짐, 서서히 나타남"
    L["Flash when below"] = "막대 깜박임"
    L["Global Options"] = "전역 설정"
    L["Group Options"] = "그룹 설정"
    L["Hidden"] = "숨김"
    L["Huge"] = "아주 크게"
    L["Large"] = "크게"
    L["Layout Options"] = "레이아웃 옵션"
    L["Left"] = "왼쪽"
    L["Lock bars during play"] = "플레이 중 막대 위치 변경 잠금"
    L["Locked To Background"] = "백그라운드 고정"
    L["Locked To Group"] = "그룹 고정"
    L["Medium"] = "보통"
    L["Never"] = "표시안함"
    L["Only show auras listed"] = "표시할 오라 리스트"
    L["Only show auras with a duration"] = "지속 시간이 있는 오라만 보이기"
    L["Only show my auras"] = "내가 시전한 오라만 보이기"
    L["Opacity"] = "불투명도"
    L["Percent Text"] = "비율 표시 위치"
    L["Reset All Group Positions"] = "모든 그룹 위치 초기화"
    L["Right"] = "오른쪽"
    L["Scale"] = "스케일"
    L["Set Color"] = "색상 설정"
    L["Show Buffs"] = "모든 버프 보이기"
    L["Show Debuffs"] = "모든 디버프 보이기"
    --[[Translation missing --]]
    L["Show in all forms"] = "Show in all forms"
    L["Show target spell"] = "대상 주문 표시"
    L["Small"] = "작게"
    --[[Translation missing --]]
    L["Snap All Bars To Groups"] = "Snap All Bars To Groups"
    L["StatusBars2 Config"] = "StatusBars2 설정"
    --[[Translation missing --]]
    L["STRING_ID_CONFIG_AURA_FILTER_ENTRY_HELP_TEXT"] = [=[Type the name of the buff/debuff you want to add to the list here and click the "Add Entry" button.
    You must type the name exactly as it appears in the tooltip.  Capitalization is important!]=]
    --[[Translation missing --]]
    L["STRING_ID_CONFIG_AURA_FILTER_LIST_HELP_TEXT"] = [=[Hides all buffs/debuffs except for the ones you add to the list below.
    However, the options you checked still affect which auras are displayed.
    For example, if you type in the name of a buff but don't have the
    "Show Buffs" checkbox checked, the buff still won't be displayed.]=]
    L["STRING_ID_CONFIG_COPY_SETTINGS_TEXT"] = "현재 사용중인 프로필에 선택한 프로필의 설정을 복사합니다."
    L["STRING_ID_CONFIG_LOCK_BARS_DURING_PLAY_HELP_TEXT"] = [=[구성 패널이 열려있는 동안 자동으로 막대의 잠금 해제됩니다.
    플레이 중 막대의 이동을 원하지 않는다면 이것을 선택하지 마십시오.]=]
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_1"] = "Original Addon by Wesslen"
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_2"] = "Version 2 rewrite by GopherYerguns"
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_3"] = "Mists of Pandaria updates by 堂吉先生 and EricTheDad"
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_4"] = "Warlords of Draenor update and ongoing maintenance by EricTheDad"
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_5"] = "번역에 도움을 주신분:"
    L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_6"] = [=[deDE: EricTheDad
    frFR: available
    itIT: available
    esES: available
    esMX: available
    ptBR: available
    ruRU: available
    zhCN: available
    koKR: 자료구조론-데스윙, nowdswdsw
    zhTW: available]=]
    L["STRING_ID_INTERFACEPANEL_HELP_TEXT_1"] = "채팅창에 \"/statusbars2\" 또는 \"/sb2\" 입력하여 이 화면을 표시하십시오."
    L["STRING_ID_INTERFACEPANEL_HELP_TEXT_2"] = "채팅창에 \"/statusbars2 config\" 또는 \"/sb2 config\" 입력하거나 아래 버튼을 눌러 구성 모드를 활성화 하십시오."
    L["STRING_ID_INTERFACEPANEL_TRANSLATORS_NEEDED"] = [=[번역이 필요합니다! 
    http://wow.curseforge.com/addons/statusbars2/localization 으로 이동하십시오.
    만약 도움을 받으시려면 EricTheDad 에게 메시지를 보내주세요!]=]
    L["STRING_ID_MOVE_BAR_HELP_TEXT"] = [=["Alt"를 누르면 개별 막대가 이동됩니다.
    "Ctrl"을 누르면 지정 그룹이 이동됩니다.
    "Ctrl" + "Alt"를 누르면 전체 그룹이 이동됩니다.]=]
    L["Text Display Options"] = "텍스트 표시 옵션"
    L["Text Size"] = "글자 크기"
    L["Thousand Separators Only"] = "천 단위 구분 기호 표현"
    L["Unformatted"] = "형식없음"
    end

------------------------------------------------------
if (GetLocale() == "zhTW") then
    
    -- L["Abbreviated"] = ""
    -- L["Add Entry"] = ""
    L["Always"] = "總是" -- Needs review
    L["Auto"] = "自動" -- Needs review
    -- L["Auto-layout order"] = ""
    -- L["Automatic"] = ""
    -- L["Available"] = ""
    -- L["Bar Options"] = ""
    -- L["Bar Select"] = ""
    -- L["Clear"] = ""
    -- L["Color"] = ""
    L["Combat"] = "戰鬥" -- Needs review
    -- L["Delete Entry"] = ""
    -- L["Enable Aura Tooltips"] = ""
    L["Enabled"] = "已啟用" -- Needs review
    -- L["Enable help tooltips"] = ""
    -- L["Fade bars in and out"] = ""
    -- L["Flash when below"] = ""
    -- L["Global Options"] = ""
    -- L["Group Options"] = ""
    L["Hidden"] = "隱藏" -- Needs review
    L["Huge"] = "特大" -- Needs review
    L["Large"] = "大" -- Needs review
    -- L["Layout Options"] = ""
    L["Left"] = "左" -- Needs review
    -- L["Lock bars during play"] = ""
    -- L["Locked To Background"] = ""
    -- L["Locked To Group"] = ""
    L["Medium"] = "中" -- Needs review
    -- L["Never"] = ""
    -- L["Only show auras listed"] = ""
    -- L["Only show auras with a duration"] = ""
    -- L["Only show my auras"] = ""
    -- L["Opacity"] = ""
    L["Percent Text"] = "百分比文字" -- Needs review
    -- L["Reset All Group Positions"] = ""
    L["Right"] = "右" -- Needs review
    L["Scale"] = "比例" -- Needs review
    -- L["Set Color"] = ""
    -- L["Show Buffs"] = ""
    -- L["Show Debuffs"] = ""
    -- L["Show in all forms"] = ""
    -- L["Show target spell"] = ""
    L["Small"] = "小" -- Needs review
    -- L["Snap All Bars To Groups"] = ""
    L["StatusBars2 Config"] = "StatusBars2 設置" -- Needs review
    -- L["STRING_ID_CONFIG_AURA_FILTER_ENTRY_HELP_TEXT"] = ""
    -- L["STRING_ID_CONFIG_AURA_FILTER_LIST_HELP_TEXT"] = ""
    -- L["STRING_ID_CONFIG_COPY_SETTINGS_TEXT"] = ""
    -- L["STRING_ID_CONFIG_LOCK_BARS_DURING_PLAY_HELP_TEXT"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_1"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_2"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_3"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_4"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_5"] = ""
    -- L["STRING_ID_INTERFACEPANEL_CREDITS_TEXT_6"] = ""
    -- L["STRING_ID_INTERFACEPANEL_HELP_TEXT_1"] = ""
    -- L["STRING_ID_INTERFACEPANEL_HELP_TEXT_2"] = ""
    -- L["STRING_ID_INTERFACEPANEL_TRANSLATORS_NEEDED"] = ""
    -- L["STRING_ID_MOVE_BAR_HELP_TEXT"] = ""
    L["Text Display Options"] = "文字顯示選項" -- Needs review
    L["Text Size"] = "文字大小" -- Needs review
-- L["Thousand Separators Only"] = ""
-- L["Unformatted"] = ""
end

------------------------------------------------------
-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateHealthBar
--
--  Description:    Create a health bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetLocalizedText(key)
    return L[key];
end
