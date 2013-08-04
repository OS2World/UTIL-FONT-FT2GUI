/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
        call VROptions 'NoEchoQuit'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         _DisableFreetypeOptions
*/
_DisableFreetypeOptions: 
    ok = VRset("RB_IBM_TrueType","set",1)        
    ok = VRset("DT_OpenFaces","Enabled",0)
    ok = VRSet("EF_OpenFaces","Enabled",0)
    ok = VRSet("CB_Use_Fake_Bold","Enabled", 0)
    ok = VRSet("CB_Use_Netscape_Fix","Enabled", 0)
    ok = VRSet("CB_Add_Uni_Encode","Enabled", 0)
    ok = VRSet("CB_Use_Facename_Alias","Enabled", 0)
    ok = VRSet("PB_Save","Enabled", 0)
    ok = VRSet("EF_OpenFaces","BackColor","PaleGray")
return

/*:VRX         _EnableFreeTypeOptions
*/
_EnableFreeTypeOptions: 
    ok = VRset("RB_FreeType","set",1)
    ok = VRset("DT_OpenFaces","Enabled",1)
    ok = VRset("EF_OpenFaces","Enabled",1)
    ok = VRSet("EF_OpenFaces","BackColor","White")
    ok = VRSet("CB_Use_Fake_Bold","Enabled", 1)
    ok = VRSet("CB_Use_Netscape_Fix","Enabled", 1)
    ok = VRSet("CB_Add_Uni_Encode","Enabled", 1)
    ok = VRSet("CB_Use_Facename_Alias","Enabled", 1)
    ok = VRSet("PB_Save","Enabled", 1)
return

/*:VRX         _QueryCurrentTrueTypeDriver
*/
_QueryCurrentTrueTypeDriver: 
    app = "PM_Font_Drivers"
    key = "TRUETYPE"

    val = SysIni('USER', app, key)

    if val = "ERROR:" then val = "none"
    /* strip the terminating NULL character */
    else val = substr(val, 1, pos(d2c(0), val) - 1)

    if pos('TRUETYPE',translate(val)) > 1 then do
        ok = VRMethod("RB_IBM_TrueType","setfocus")
        call _DisableFreeTypeOptions
    end

    if pos('FREETYPE',translate(val)) > 1 then do
        ok = VRMethod("RB_FreeType","setfocus")
        call _EnableFreeTypeOptions
        call _QueryFreeTypeOptions
    end
return

/*:VRX         _QueryFreeTypeOptions
*/
_QueryFreeTypeOptions: 
    app = "FreeType/2"
    key = "OpenFaces"
    val = SysIni('USER', app, key)
    if val = "ERROR:" then val = "not set"
    /* strip the terminating NULL character */
    else val = substr(val, 1, pos(d2c(0), val) - 1)
    ok = VRSet("EF_OpenFaces","Value",val)

    key = "Use_Fake_Bold"
    val = SysIni('USER', app, key)
    if val = "ERROR:" then val = 0
    /* strip the terminating NULL character */
    else val = substr(val, 1, pos(d2c(0), val) - 1)
    ok = VRSet("CB_Use_Fake_Bold","Set", val)

    key = "Use_Netscape_Fix"
    val = SysIni('USER', app, key)
    if val = "ERROR:" then val = 0
    /* strip the terminating NULL character */
    else val = substr(val, 1, pos(d2c(0), val) - 1)
    ok = VRSet("CB_Use_Netscape_Fix","Set", val)

    key = "Add_Uni_Encode"
    val = SysIni('USER', app, key)
    if val = "ERROR:" then val = 0
    /* strip the terminating NULL character */
    else val = substr(val, 1, pos(d2c(0), val) - 1)
    ok = VRSet("CB_Add_Uni_Encode","Set", val)

    key = "Use_Facename_Alias"
    val = SysIni('USER', app, key)
    if val = "ERROR:" then val = 0
    /* strip the terminating NULL character */
    else val = substr(val, 1, pos(d2c(0), val) - 1)
    ok = VRSet("CB_Use_Facename_Alias","Set", val)

return

/*:VRX         CB_Add_Uni_Encode_Click
*/
CB_Add_Uni_Encode_Click: 
    ok = VRseT("PB_Undo","Enabled",1)
return

/*:VRX         CB_Use_Facename_Alias_Click
*/
CB_Use_Facename_Alias_Click: 
    ok = VRseT("PB_Undo","Enabled",1)
return

/*:VRX         CB_Use_Fake_Bold_Click
*/
CB_Use_Fake_Bold_Click: 
    ok = VRseT("PB_Undo","Enabled",1)
return

/*:VRX         CB_Use_Netscape_Fix_Click
*/
CB_Use_Netscape_Fix_Click: 
    ok = VRseT("PB_Undo","Enabled",1)
return

/*:VRX         EF_OpenFaces_Change
*/
EF_OpenFaces_Change: 
    ok = VRSet("PB_Save","Enabled", 0)
    ok = VRset("TM_OpenFaces","Enabled",1)
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:
    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window
return

/*:VRX         Main_Close
*/
Main_Close:
    call Quit
return

/*:VRX         Main_Create
*/
Main_Create: 
    ok = VRRedirectStdIO('OFF')

    call RxFuncAdd "SysLoadFuncs", "RexxUtil", "SysLoadFuncs"
    call SysLoadFuncs

    call _QueryCurrentTrueTypeDriver
return

/*:VRX         PB_Exit_Click
*/
PB_Exit_Click: 
    call Quit
return

/*:VRX         PB_Save_Click
*/
PB_Save_Click: 
    bootdrive = SysSearchPath('PATH', 'OS2.INI')
    bootdrive = left(bootdrive, 1)

    app = "PM_Font_Drivers"
    key = "TRUETYPE"

    if VRGet("RB_IBM_trueType","set") then do
        /* look for TRUETYPE.DLL */
        rc = SysFileTree(left(bootdrive,1) || ":\OS2\DLL\TRUETYPE.DLL", "file", "F")

        if file.0 = 1 then do
           val = "\OS2\DLL\TRUETYPE.DLL" || d2c(0)
           SysIni('BOTH', app, key, val)
        end
        /* else no driver file! */
    end
    if VRGet("RB_FreeType","set") then do
        /* look for FREETYPE.DLL */
        rc = SysFileTree(left(bootdrive,1) || ":\OS2\DLL\FREETYPE.DLL", "file", "F")

        if file.0 = 1 then do
            val = "\OS2\DLL\FREETYPE.DLL" || d2c(0)
            SysIni('BOTH', app, key, val)
            app = "FreeType/2"

            key = "OpenFaces"
            val = VRget("EF_"key,"Value")
            szval = val || d2c(0)
            rc = SysIni('USER', app, key, szval)

            key = "Use_Fake_Bold"
            val = VRget("CB_"key,"Set")
            szval = val || d2c(0)
            rc = SysIni('USER', app, key, szval)

            key = "Use_Netscape_Fix"
            val = VRget("CB_"key,"Set")
            szval = val || d2c(0)
            rc = SysIni('USER', app, key, szval)
    
            key = "Add_Uni_Encode"
            val = VRget("CB_"key,"Set")
            szval = val || d2c(0)
            rc = SysIni('USER', app, key, szval)
        end
        /* else no driver file! */
    end
    Buttons.1 = "OK"
    Buttons.0 = 1
    id = VRMessage( VRWindow(), "Please reboot to make changes effective!", "TrueType configuration changed", "Information", "Buttons.", buttons.1, buttons.1 )

    call _QueryCurrentTrueTypeDriver
return

/*:VRX         PB_Undo_Click
*/
PB_Undo_Click: 
    call _QueryCurrentTrueTypeDriver
return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         RB_FreeType_Click
*/
RB_FreeType_Click: 
    ok = VRseT("PB_Undo","Enabled",1)
    call _EnableFreeTypeOptions
    call _QueryFreeTypeOptions
return

/*:VRX         RB_IBM_TrueType_Click
*/
RB_IBM_TrueType_Click: 
    ok = VRseT("PB_Undo","Enabled",1)
    call _DisableFreeTypeOptions
    ok = VRseT("PB_Save","Enabled",1)
return

/*:VRX         TM_OpenFaces_Trigger
*/
TM_OpenFaces_Trigger: 
    if VRget("EF_OpenFaces","Value") < 8 then ok = VRSet("EF_OpenFaces","Value","8")
    if VRget("EF_OpenFaces","Value") > 256 then ok = VRSet("EF_OpenFaces","Value","256")
    ok = VRSet("PB_Save","Enabled", 1)
    ok = VRset("TM_OpenFaces","Enabled",0)
return

