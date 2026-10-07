

description = "FluidNC";
vendor = "MechTech Inovations";
vendorUrl = "https://github.com/benjkers/FluidNC";
longDescription = "FluidNC is a post processor for Fusion 360 that generates G-code compatible with the FluidNC firmware. It supports milling, probing, and multi-axis operations, providing options for adaptive feed control, safe retracts, and tool management.";

// >>>>> INCLUDED FROM ../common/grbl.cps
legal = "Copyright (C) 2012-2024 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45917;

extension = "nc";
setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_MACHINE_SIMULATION;
tolerance = spatial(0.001, MM);
if (typeof revision == "number" && typeof supportedFeatures != "undefined") {
  supportedFeatures |= revision >= 50328 ? FEATURE_MACHINE_ROTARY_ANGLES : 0;
}

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion
highFeedrate = (unit == MM) ? 5000 : 200;

// user-defined properties
properties = {
  // PER-OPERATION property. Note this lives inside the normal properties
  // object and is marked scope:"operation" -- it is NOT in a separate
  // operationProperties = {} object. Using that separate object caused
  // Fusion to silently suppress this entire properties list; this pattern
  // (verified against a working production Okuma post) does not.
  adaptiveFeedGoal: {
    title      : "Adaptive feed target torque %",
    description: "Torque-based adaptive feed control (M52) target for this operation, as a percentage of rated torque. The feed override is scaled continuously to hold this target -- not stepped -- so it converges smoothly rather than hunting. 0 disables goal-seeking for this operation; the machine's hard-stall and overtorque protections stay active regardless, independent of this setting. The firmware clamps to 90% max. Defaults to a deliberately low, fail-safe value: if you forget to raise it, the machine runs conservatively slow rather than risk overload/breaking a tool.",
    group      : "operationProps",
    type       : "integer",
    value      : 0,
    range      : [0, 90],
    scope      : "operation",
    enabled    : ["milling", "drilling"]
  },
  // PER-OPERATION property, same pattern as above.
  //
  // enabled:["probing"] keeps the tick off every milling operation, where it
  // would do nothing. The field itself is proven -- adaptiveFeedGoal above
  // uses it -- but "probing" as the token for Fusion's inspection operations
  // is NOT documented; Autodesk publish `scope` and not the operation-type
  // strings `enabled` accepts. If the post dialog ever comes up with its
  // properties list EMPTY, that token is the cause: delete this one line and
  // everything comes back, with the tick simply showing on every operation.
  // Ticking it somewhere it does not belong is still caught at post time by
  // the check in onCyclePoint, so nothing depends on this filter being right.
  bLevelPoint: {
    title      : "B level: use this point",
    description: "Tick this on a Probe Geometry - Surface cycle to feed its result into the B-axis levelling macro. Tick exactly TWO of them: the post captures the machine X and Z of each touch plus that operation's nominal X and Bottom Height, then calls /Probing/ProbeBLevel.nc after the second one. The macro works out how far the part is tilted about B and writes that angle into the work offset's B component, so work B0 becomes 'this part is level'. Nothing rotates. The two faces do NOT have to be at the same height: the designed step between them comes from the operations' own Bottom Heights and is taken back out of the measurement. Spread the two points as far apart in X as the part allows -- the angle resolves as probe scatter over that span. Ticked cycles pair up in program order, so four ticks means two levelling passes. Level BEFORE probing XYZ into the same offset.",
    group      : "operationProps",
    type       : "boolean",
    value      : false,
    scope      : "operation",
    enabled    : ["probing"]
  },
  homeXYOnRotary: {
    title      : "Home XY on 4th/5th axis moves",
    description: "Retracts to machine home in X and Y (in addition to the Z retract that always happens) before any 4th/5th axis repositioning move. Use this when tall or off-centre work on the rotary axis could swing into the spindle or column as it indexes. The retract uses whatever 'Safe Retracts' method is selected above.",
    group      : "homePositions",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  safePositionMethod: {
    title      : "Safe Retracts",
    description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
    group      : "homePositions",
    type       : "enum",
    values     : [
      {title:"G28", id:"G28"},
      {title:"G53", id:"G53"},
      {title:"Clearance Height", id:"clearanceHeight"}
    ],
    value: "G53",
    scope: "post"
  },
  showSequenceNumbers: {
    title      : "Use sequence numbers",
    description: "'Yes' outputs sequence numbers on each block, 'Only on tool change' outputs sequence numbers on tool change blocks only, and 'No' disables the output of sequence numbers.",
    group      : "formats",
    type       : "enum",
    values     : [
      {title:"Yes", id:"true"},
      {title:"No", id:"false"},
      {title:"Only on tool change", id:"toolChange"}
    ],
    value: "false",
    order: 1,
    scope: "post"
  },
  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group      : "formats",
    type       : "integer",
    value      : 10,
    order      : 2,
    scope      : "post"
  },
  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group      : "formats",
    type       : "integer",
    value      : 1,
    order      : 3,
    scope      : "post"
  },
  separateWordsWithSpace: {
    title      : "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  outputToolChange: {
    title      : "Output tool change (Tn M6)",
    description: "Outputs the tool number and M6 together on every tool change (e.g. 'T2 M6'). FluidNC's tool changer needs both together to work at all -- M6 is what actually triggers a tool change, and the T-number tells it which tool -- so these used to be two separate properties that could be set inconsistently (e.g. M6 off with the tool number still on, silently breaking every tool change with no output to show why). Disable only if you don't want any tool-change output at all (e.g. single-tool jobs).",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  outputToolLengthCheck: {
    title      : "Tool length check",
    description: "'Yes' outputs the tool gauge length safety check (CheckToolGauge.nc) after every tool change. 'No' still outputs #<_fusion_tool_gauge> (used for a safe toolsetter approach on manual tools) but skips the verification/alarm call.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  outputToolGaugeVariable: {
    title      : "Output tool gauge variable",
    description: "'Yes' writes #<_fusion_tool_gauge> before each tool change. The ATC uses it as a hint for a faster toolsetter approach on manual tools, and the tool length check compares against it. 'No' omits it entirely, in which case the ATC falls back to a full-range approach and the length check is skipped.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  probeLogToSD: {
    title      : "Log probe results to SD card",
    description: "'Yes' appends every probing result to /probe_log.csv on the controller's SD card, for trending or record keeping. Independent of Print Results. Clear the file with $Probe/LogClear, view it with $Probe/LogShow.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  probePauseAfterResults: {
    title      : "Pause after probe results",
    description: "'Yes' holds the program with a pause after each probing cycle prints its result, so the numbers can be read before machining continues. Only has an effect on operations with Print Results enabled.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  probeDumpCycleProps: {
    title      : "Probe: dump cycle properties",
    description: "Diagnostic only. Writes every property Fusion exposes on a probing cycle into the output as comments, so the real property names and values can be read off. Leave off for normal use.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  }
};

// wcs definiton
wcsDefinitions = {
  useZeroOffset: false,
  wcs          : [
    {name:"Standard", format:"G", range:[54, 59]}
  ]
};

var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4)});
var abcFormat = createFormat({decimals:3, type:FORMAT_REAL, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 1 : 2)});
var inverseTimeFormat = createFormat({decimals:3, type:FORMAT_REAL});
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, type:FORMAT_REAL}); // seconds - range 0.001-1000
var taperFormat = createFormat({decimals:1, scale:DEG});

var xOutput = createOutputVariable({onchange:function() {state.retractedX = false;}, prefix:"X"}, xyzFormat);
var yOutput = createOutputVariable({onchange:function() {state.retractedY = false;}, prefix:"Y"}, xyzFormat);
var zOutput = createOutputVariable({onchange:function() {state.retractedZ = false;}, prefix:"Z"}, xyzFormat);
var aOutput = createOutputVariable({prefix:"A"}, abcFormat);
var bOutput = createOutputVariable({prefix:"B"}, abcFormat);
var cOutput = createOutputVariable({prefix:"C"}, abcFormat);
var feedOutput = createOutputVariable({prefix:"F"}, feedFormat);
var inverseTimeOutput = createOutputVariable({prefix:"F", control:CONTROL_FORCE}, inverseTimeFormat);
var sOutput = createOutputVariable({prefix:"S", control:CONTROL_FORCE}, rpmFormat);

// circular output
var iOutput = createOutputVariable({prefix:"I", control:CONTROL_FORCE}, xyzFormat);
var jOutput = createOutputVariable({prefix:"J", control:CONTROL_FORCE}, xyzFormat);
var kOutput = createOutputVariable({prefix:"K", control:CONTROL_FORCE}, xyzFormat);

var gMotionModal = createOutputVariable({}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createOutputVariable({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createOutputVariable({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createOutputVariable({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createOutputVariable({}, gFormat); // modal group 6 // G20-21

var settings = {
  coolant: {
    // samples:
    // {id: COOLANT_THROUGH_TOOL, on: 88, off: 89}
    // {id: COOLANT_THROUGH_TOOL, on: [8, 88], off: [9, 89]}
    // {id: COOLANT_THROUGH_TOOL, on: "M88 P3 (myComment)", off: "M89"}
    coolants: [
      {id:COOLANT_FLOOD, on:8},
      {id:COOLANT_MIST},
      {id:COOLANT_THROUGH_TOOL},
      {id:COOLANT_AIR},
      {id:COOLANT_AIR_THROUGH_TOOL},
      {id:COOLANT_SUCTION},
      {id:COOLANT_FLOOD_MIST},
      {id:COOLANT_FLOOD_THROUGH_TOOL},
      {id:COOLANT_OFF, off:9}
    ],
    singleLineCoolant: false, // specifies to output multiple coolant codes in one line rather than in separate lines
  },
  retract: {
    cancelRotationOnRetracting: false, // specifies that rotations (G68) need to be canceled prior to retracting
    methodXY                  : undefined, // special condition, overwrite retract behavior per axis
    methodZ                   : undefined, // was hardcoded "G28", which silently overrode the "Safe Retracts" property for every Z retract -- undefined lets that property apply
    useZeroValues             : ["G28", "G30"], // enter property value id(s) for using "0" value instead of machineConfiguration axes home position values (ie G30 Z0)
    homeXY                    : {onIndexing:false, onToolChange:false, onProgramEnd:{axes:[X, Y]}} // Specifies when XY should be homed in XY (sample: onIndexing:[X,Y]). Options can be combined
  },
  machineAngles: { // refer to https://cam.autodesk.com/posts/reference/classMachineConfiguration.html#a14bcc7550639c482492b4ad05b1580c8
    controllingAxis: ABC,
    type           : PREFER_PREFERENCE,
    options        : ENABLE_ALL
  },
  workPlaneMethod: {
    useTiltedWorkplane    : false, // specifies that tilted workplanes should be used (ie. G68.2, G254, PLANE SPATIAL, CYCLE800), can be overwritten by property
    eulerConvention       : EULER_ZXZ_R, // specifies the euler convention (ie EULER_XYZ_R), set to undefined to use machine angles for TWP commands ('undefined' requires machine configuration)
    eulerCalculationMethod: "standard", // ('standard' / 'machine') 'machine' adjusts euler angles to match the machines ABC orientation, machine configuration required
    cancelTiltFirst       : true, // cancel tilted workplane prior to WCS (G54-G59) blocks
    forceMultiAxisIndexing: false, // force multi-axis indexing for 3D programs
    optimizeType          : OPTIMIZE_AXIS // can be set to OPTIMIZE_NONE, OPTIMIZE_BOTH, OPTIMIZE_TABLES, OPTIMIZE_HEADS, OPTIMIZE_AXIS. 'undefined' uses legacy rotations
  },
  comments: {
    permittedCommentChars: " abcdefghijklmnopqrstuvwxyz0123456789.,=_-*:", // letters are not case sensitive, use option 'outputFormat' below. Set to 'undefined' to allow any character
    prefix               : "(", // specifies the prefix for the comment
    suffix               : ")", // specifies the suffix for the comment
    outputFormat         : "ignoreCase", // can be set to "upperCase", "lowerCase" and "ignoreCase". Set to "ignoreCase" to write comments without upper/lower case formatting
    maximumLineLength    : 80 // the maximum number of characters allowed in a line, set to 0 to disable comment output
  },
  maximumSequenceNumber       : undefined, // the maximum sequence number (Nxxx), use 'undefined' for unlimited
  maximumToolNumber           : 9999, // specifies the maximum allowed tool number
  outputToolLengthCompensation: false, // specifies if tool length compensation code should be output (G43)
  outputToolLengthOffset      : false, // specifies if tool length offset code should be output (Hxx)
  supportsOptionalBlocks      : false, // specifies if optional block output is supported
  // Cancel RPCP before every G53 retract. Those retracts are the machine's
  // own moves -- clearing the part, going to the rack, going to the
  // toolsetter -- and with M128 active they would be run through the
  // kinematics instead, which with B off zero drags X and Z along with them.
  // A retract also precedes every tool change, so this is what guarantees the
  // ATC's macro runs with RPCP off; the whole thing works in machine
  // coordinates. writeInitialPositioning turns it back on for any section
  // that needs it.
  allowCancelTCPBeforeRetracting: true,
  // fixed settings below, do not modify
  supportsTCP                 : true // FluidNC TCPCartesian kinematics, switched with M128/M129
};

// ===========================================================================
// NO-ATC MACHINES -- renumber the tools out of the rack range
// ===========================================================================
// atc_custom.h decides what is a rack tool with
//     is_rack_tool(t) { return t >= _first_tool_number && t < _first_tool_number + _tool_count; }
// which on this machine is T2..T7. T1 is PROBE_TOOL and T100 is
// GAUGE_SETTER_TOOL. EVERY other number is already handled as a manual tool:
// the ATC parks over the toolsetter and waits on M0 instead of going to a
// pocket, then measures the gauge length it does not have stored.
//
// So nothing has to be switched off for a machine without a changer. Each
// tool only has to land outside T2..T7 and the existing firmware path does
// the right thing -- including Fusion's machine simulation, which draws the
// manual sequence for any out-of-rack number without being told (see
// atcSimulateToolChange: newSlot < 0 takes the manual branch).
//
// T1 and T100 pass straight through. Renumbering either would break probing
// or toolsetter calibration, since the firmware keys off those two numbers.
// ===========================================================================
// ---------------------------------------------------------------------
// FIXED BEHAVIOUR
//
// These five were post properties. They are constants now so the post
// dialog stays short -- every one of them was only ever going to be left
// on its default. Change them here if that stops being true.
// ---------------------------------------------------------------------
// "auto" decides from the machine definition's declared tool count;
// "yes" keeps rack tool numbers whatever it says; "no" always renumbers.
var ATC_PRESENT = "auto";
// Comma-separated text matched against the machine's vendor/model/
// description, as a fallback for a definition whose tool count is wrong.
// "" switches the fallback off.
var NO_ATC_NAME_MATCH = "";
// "fusion" uses the machine selected in the setup, which is what lets
// Fusion simulate with the machine model; "post" always uses the built-in
// B-axis definition. Either way the built-in one covers a setup with no
// machine selected.
var MACHINE_CONFIG_SOURCE = "fusion";
// Replay the tool changer's real path into the machine simulation.
var SIMULATE_ATC_MOVES = true;
// Which offset ProbeBLevel.nc writes its angle into. 0 = the active one.
var B_LEVEL_OFFSET = 0;

var PROBE_TOOL = 1;          // atc_custom.h PROBE_TOOL
var GAUGE_SETTER_TOOL = 100; // atc_custom.h GAUGE_SETTER_TOOL

// Derived from atcGeometry rather than written out, so a change to the rack
// in config.yaml only has to be mirrored in one place in this post. Computed
// on call, not at load time: atcGeometry is declared further down the file.
function manualToolFirst() {
  return atcGeometry.firstToolNumber + atcGeometry.slots.length; // 2 + 6 = T8
}

function manualToolLast() {
  return GAUGE_SETTER_TOOL - 1;
}

var machineVendor = "";
var machineModel = "";
var machineDescription = "";
var machineWasSelected = false;
var machineToolCount = -1;   // magazine capacity, for the header only
var machineHasChanger;       // the definition's tool-changer tick; undefined = not answered
var usingFusionMachine = false; // true when the setup's own machine is in use
var noAtcMachine = false;
var toolRenumber = {};       // Fusion number -> posted number
var toolRenumberList = [];   // the same, in first-use order, for the header

function captureMachineIdentity() {
  // Read all of this BEFORE defineMachine() runs. That function replaces
  // machineConfiguration with one built from scratch here, which declares no
  // tools and carries no vendor, model or description -- so by the time
  // anything else looks, the selected machine's definition is gone. This is
  // also why writeProgramHeader's 'Machine' block has been coming out empty.
  machineWasSelected = false;
  try {
    machineWasSelected = machineConfiguration.isReceived() ? true : false;
  } catch (e) {
    machineWasSelected = false;
  }
  machineVendor = safeMachineCall("getVendor", "");
  machineModel = safeMachineCall("getModel", "");
  machineDescription = safeMachineCall("getDescription", "");
  var n = safeMachineCall("getNumberOfTools", -1);
  machineToolCount = (typeof n == "number") ? n : -1;
  // THE tick in the machine definition: "Automatic tool changer" there,
  // getToolChanger() here, isToolChangerAutomatic in the Fusion API --
  // "If your machine has an automatic tool changer, set this to true. For
  // machines with manual tool change capabilities, set this to false."
  //
  // This is the question being asked, so it is what decides. The tool count
  // is a magazine capacity and says nothing about whether there is a changer
  // to put tools in it; it is carried along for the header only.
  //
  // undefined means the kernel did not answer at all, which is reported
  // rather than guessed around.
  var v = safeMachineCall("getToolChanger", undefined);
  machineHasChanger = (typeof v == "boolean") ? v : undefined;
}

function safeMachineCall(fn, fallback) {
  // Guarded because an absent machine configuration makes these throw rather
  // than return empty, and no machine selected is a perfectly normal case.
  try {
    if (typeof machineConfiguration[fn] != "function") {
      return fallback;
    }
    var v = machineConfiguration[fn]();
    if (typeof fallback == "string") {
      return v ? String(v) : "";
    }
    return v;
  } catch (e) {
    return fallback;
  }
}

function machineIdentityText() {
  var parts = [];
  if (machineVendor) {
    parts.push(machineVendor);
  }
  if (machineModel) {
    parts.push(machineModel);
  }
  if (machineDescription) {
    parts.push(machineDescription);
  }
  return parts.join(" ");
}

// The answer comes from the MACHINE DEFINITION, because the rack is a
// property of the machine and the machine Fusion has selected is the thing
// that knows. Specifically from its tool-changer tick, not from the tool
// count -- a magazine capacity says nothing about whether there is a changer.
function noAtcReason() {
  var mode = ATC_PRESENT;
  if (mode == "yes") {
    return null;
  }
  if (mode == "no") {
    return "forced by ATC_PRESENT in the post";
  }
  if (!machineWasSelected) {
    return "no machine is selected in the setup";
  }
  if (machineHasChanger === false) {
    return "the machine definition has no automatic tool changer";
  }
  // Fallback for a definition that does not fill the field in at all.
  var needles = String(NO_ATC_NAME_MATCH).toLowerCase().split(",");
  var hay = machineIdentityText().toLowerCase();
  for (var i = 0; hay && i < needles.length; ++i) {
    var n = needles[i].replace(/^\s+/, "").replace(/\s+$/, "");
    if (n && hay.indexOf(n) >= 0) {
      return "the machine name matches '" + n + "'";
    }
  }
  return null;
}

function passThroughTool(n) {
  return n == PROBE_TOOL || n == GAUGE_SETTER_TOOL;
}

function buildToolRenumber() {
  toolRenumber = {};
  toolRenumberList = [];
  if (!noAtcMachine) {
    return;
  }
  // First-use order, so the numbers climb in the order the operator will be
  // asked for them rather than in whatever order Fusion's tool library is in.
  var next = manualToolFirst();
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var t = getSection(i).getTool().number;
    if (passThroughTool(t) || toolRenumber[t] !== undefined) {
      continue;
    }
    if (next > manualToolLast()) {
      error(localize("This job needs more than " + (manualToolLast() - manualToolFirst() + 1) +
        " manual tools, which would run past T" + manualToolLast() +
        " into the toolsetter reference tool T" + GAUGE_SETTER_TOOL + "."));
      return;
    }
    toolRenumber[t] = next;
    toolRenumberList.push([t, next]);
    ++next;
  }
}

function mapTool(n) {
  var m = toolRenumber[n];
  return (m === undefined) ? n : m;
}

// The offset of whichever rotary axis is enabled -- the pivot position, which
// only matters when TCP is off and Fusion is doing that arithmetic itself.
// Guarded: not every kernel revision exposes getOffset().
function rotaryAxisOffset() {
  try {
    var axes = [machineConfiguration.getAxisU(), machineConfiguration.getAxisV(),
      machineConfiguration.getAxisW()];
    for (var i = 0; i < axes.length; ++i) {
      if (axes[i].isEnabled() && typeof axes[i].getOffset == "function") {
        return axes[i].getOffset();
      }
    }
  } catch (e) {
    return undefined;
  }
  return undefined;
}

// Checks the selected machine actually describes this one. Called after
// activateMachine(), which is where tcp.isSupportedByMachine is worked out
// from the axes. Each of these would otherwise change the posted output
// silently rather than failing, which is the worst way to find out.
function validateMachineDefinition() {
  if (!usingFusionMachine) {
    return;
  }
  var problems = [];
  if (!machineConfiguration.isMultiAxisConfiguration()) {
    problems.push("it has no rotary axis. Add the B axis in Machine Builder, " +
      "or set MACHINE_CONFIG_SOURCE to \"post\" in the post.");
  } else {
    if (!machineConfiguration.isMachineCoordinate(1)) {
      problems.push("its rotary axis is not B. TCPCartesian compensates a B " +
        "rotary, so set the axis coordinate to B.");
    }
    if (machineConfiguration.isHeadConfiguration()) {
      problems.push("its rotary axis is on the head. This one carries the " +
        "part, so it has to be defined as a table axis -- the distinction " +
        "decides which side of the cut gets compensated.");
    }
    // TCP off is a supported way to run, not a fault. Both modes do full
    // multi-axis moves; what changes is WHO compensates the rotary pivot.
    //
    //   TCP on   the posted XYZ is the tool tip in the part frame and the
    //            firmware turns it into machine moves. M128/M129 switch it.
    //   TCP off  Fusion has already folded the pivot geometry into the
    //            posted XYZ, so the firmware must leave it alone.
    //
    // Either is fine; mixing them is not, and that is what the checks below
    // are for. The per-operation decision is already made correctly further
    // down by isTCPSupportedByOperation(), which goes off the section's
    // optimised TCP mode -- with TCP off in the definition Fusion optimises
    // the positions itself and the post never emits M128.
    if (!tcp.isSupportedByMachine) {
      // With TCP off, Fusion does the pivot arithmetic, which it can only do
      // from the axis offset in the definition. A zero offset means it has
      // not been entered, and every multi-axis move would be wrong by the
      // whole pivot distance.
      var off = rotaryAxisOffset();
      if (off !== undefined && !off.isNonZero()) {
        warning(localize("TCP is off, so Fusion compensates the rotary pivot " +
          "itself -- but the B axis offset in the machine definition is zero. " +
          "Enter the pivot position there, or every multi-axis move will be " +
          "out by the pivot distance."));
      }
    }
  }
  for (var i = 0; i < problems.length; ++i) {
    error(localize("Machine definition '" + (machineIdentityText() || "unnamed") +
      "' cannot drive this post: " + problems[i]));
  }
}


function onOpen() {
  // define and enable machine configuration
  receivedMachineConfiguration = machineConfiguration.isReceived();
  captureMachineIdentity(); // must precede defineMachine, which wipes it
  if (typeof defineMachine == "function") {
    defineMachine(); // hardcoded machine configuration
  }
  activateMachine(); // enable the machine optimizations and settings
  validateMachineDefinition(); // after activateMachine: it works out TCP support

  noAtcMachine = noAtcReason(); // the reason string, or null when there is a rack
  buildToolRenumber();

  // One file per operation calls onOpen repeatedly in the same post run, so
  // both of these have to start fresh for each output file. atcSimulatedTool
  // in particular would otherwise claim the spindle still holds the last
  // file's tool, and show a drop that the real machine will not make.
  bLevelPointCount = 0;
  atcSimulatedTool = -1;

  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  // Home XY on rotary indexing, if enabled. The Z retract before an
  // indexing move already happens unconditionally in setWorkPlane(); this
  // adds the XY home on top of it. Uses the {axes:[...]} form to match
  // homeXY.onProgramEnd -- getRetractParameters() reads arguments[0].axes,
  // so a bare [X, Y] array would not work here.
  if (getProperty("homeXYOnRotary")) {
    settings.retract.homeXY.onIndexing = {axes:[X, Y]};
  }

  if (programName) {
    writeComment(programName);
  }
  if (programComment) {
    writeComment(programComment);
  }
  writeProgramHeader();

  // absolute coordinates and feed per min
  writeProgramStart();
  validateCommonParameters();
}

function writeProgramStart() {
  forceModals();
  gUnitModal.reset();
  writeBlock(gAbsIncModal.format(90), gFeedModeModal.format(94));
  writeBlock(gPlaneModal.format(17));
  writeBlock(gUnitModal.format(unit == MM ? 21 : 20));
  // Assert RPCP off, like G90 and G21 above. M128/M129 is modal in the
  // CONTROLLER and survives the end of a program, but the post only assumes
  // state.tcpIsActive starts false -- so setTCP(false) would write nothing
  // and a program left in M128 by the last job would still be in it.
  //
  // That matters most with TCP off in the machine definition, where Fusion
  // has already folded the pivot into the posted XYZ: a stale M128 would
  // have the firmware apply it a second time, on top.
  //
  // Written directly rather than through setTCP() on purpose. This is about
  // the controller's modal state before the program runs; the simulation
  // stream has not started, and setTCP() would push a TCPOFF into it and
  // flip state.lengthCompensationActive as a side effect, neither of which
  // belongs here.
  writeBlock(mFormat.format(129));
  state.tcpIsActive = false;
}

function onSection() {
  var forceSectionRestart = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();
  var insertToolCall = isToolChangeNeeded("number") || forceSectionRestart;
  var newWorkOffset = isNewWorkOffset() || forceSectionRestart;
  var newWorkPlane = isNewWorkPlane() || forceSectionRestart || (typeof defineWorkPlane == "function" &&
    Vector.diff(defineWorkPlane(getPreviousSection(), false), defineWorkPlane(currentSection, false)).length > 1e-4);

  if (insertToolCall || newWorkOffset || newWorkPlane || state.tcpIsActive || currentSection.isMultiAxis()) {
    if (insertToolCall && !isFirstSection()) {
      onCommand(COMMAND_COOLANT_OFF); // turn off coolant before retract during tool change
      onCommand(COMMAND_STOP_SPINDLE); // stop spindle before retract during tool change
    }
    writeRetract(Z); // retract
    if (isFirstSection()) {
      // The kernel's first-section block normally does
      //     positionABC(new Vector(0, 0, 0));
      // here. Removed: it rapids the rotary to work B0 BEFORE writeWCS and
      // before the tool change, so the B0 it drives to belongs to whatever
      // offset the previous program left selected -- any machine angle at
      // all. It is redundant as well, because this section's own
      // orientation is indexed later by setWorkPlane -> positionABC(abc,
      // true), after G54 is out.
      //
      // The only thing lost is that getWorkPlaneMachineABC() assumes
      // currentABC = (0,0,0) on the first section, which the call used to
      // make true. With a single B rotary that assumption only picks
      // between B and B+-360, so the cost is which way round it unwinds.
      forceABC();
    } else {
    }
  }

  writeln("");

  writeComment(getParameter("operation-comment", ""));

  // tool change
  if (insertToolCall) {
    if (!state.retractedZ) {
      writeRetract(Z);
    }
    writeToolCall(tool, insertToolCall);
  }
  startSpindle(tool, insertToolCall);

  // Adaptive feed control (M52) -- per-operation torque-goal, see
  // the adaptiveFeedGoal property above -- a scope:"operation" integer
  // percentage (0-90), read per-section so each toolpath can differ.
  // M52 Pn itself takes a 0-0.9 FRACTION, converted in setAdaptiveFeed().
  // The actual M52 lines are emitted by updateAdaptiveFeedForMovement()
  // as moves transition between cutting and non-cutting, not here. The
  // firmware clamps the fraction to 0.9 max and treats 0 as "disable
  // goal-seeking" -- the hard-stall and overtorque protections stay
  // active regardless.
  var adaptiveFeedGoalPercent;
  if (currentSection.properties && currentSection.properties.adaptiveFeedGoal !== undefined) {
    adaptiveFeedGoalPercent = parseInt(currentSection.properties.adaptiveFeedGoal, 10);
  } else {
    adaptiveFeedGoalPercent = parseInt(getProperty("adaptiveFeedGoal", 0), 10);
  }
  if (isNaN(adaptiveFeedGoalPercent)) {
    adaptiveFeedGoalPercent = 0;
  }
  currentAdaptiveFeedGoal = adaptiveFeedGoalPercent;
  // Always start an operation with adaptive feed off -- the approach and
  // lead-in happen first, and updateAdaptiveFeedForMovement() turns it on
  // when real cutting begins.
  setAdaptiveFeed(false);

  // Output modal commands here
  writeBlock(gPlaneModal.format(17), gAbsIncModal.format(90), gFeedModeModal.format(94));

  // wcs
  if (insertToolCall) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }
  writeWCS(currentSection, true);

  var abc = defineWorkPlane(currentSection, !machineConfiguration.isHeadConfiguration());

  setCoolant(tool.coolant); // writes the required coolant codes

  forceXYZ();

  // prepositioning
  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  var isRequired = insertToolCall || state.retractedZ || !state.lengthCompensationActive || (!isFirstSection() && getPreviousSection().isMultiAxis());
  writeInitialPositioning(initialPosition, isRequired);
}

function onDwell(seconds) {
  var maxValue = 99999.999;
  if (seconds > maxValue) {
    warning(subst(localize("Dwelling time of '%1' exceeds the maximum value of '%2' in operation '%3'"), seconds, maxValue, getParameter("operation-comment", "")));
  }
  seconds = clamp(0.001, seconds, 99999.999);
  writeBlock(gFormat.format(4), "P" + secFormat.format(seconds));
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock(sOutput.format(spindleSpeed));
}

// ---------------------------------------------------------------------
// Native Fusion probing cycles (Setup > Probe / Probe toolpaths)
//
// Fusion posts these through onCyclePoint(x, y, z) with the cycle type in
// the global `cycleType`/`cycle` object. Anything we don't explicitly
// handle here falls through to expandCyclePoint(), same as normal
// drilling cycles (FluidNC has no native canned cycles, so those are
// already expanded into plain moves -- this is the same mechanism).
//
// The actual probe motion + math lives in Macros/Probe*Edge.nc /
// ProbeZSurface.nc on the SD card, not here -- this function just sets
// the named parameters those macros expect and calls them via $SD/Run=.
// Currently implemented: probing-x, probing-y, probing-z,
// probing-xy-outer-corner, probing-xy-inner-corner.
// ---------------------------------------------------------------------

// Captured via onParameter below -- Fusion's "probe measure" feed rate,
// used for the second (accurate) touch. Falls back to a fraction of the
// cycle's normal probe feed if the operation didn't set one.
var probeFeedSlow = undefined;
// Fusion's "link" feed rate -- the speed for positioning moves made with
// the probe in the spindle. Every such move is protected, so this is the
// speed at which a G38.3 travels before it hits anything.
var probeFeedLink = undefined;

function onParameter(name, value) {
  if (name == "operation:tool_feedProbeLink") {
    probeFeedLink = value;
  }
  if (name == "operation:tool_feedProbeMeasure") {
    probeFeedSlow = value;
  }
}

// Every probing macro lives in this folder on the SD card.
var PROBING_DIR = "/Probing/";

function runProbeMacro(name) {
  writeBlock("$SD/Run=" + PROBING_DIR + name);
}

// Diagnostic: dump every property Fusion exposes on the probing cycle,
// as comments. Turn on the "Probe: dump cycle properties" post property,
// post one operation, and the output lists the real property names and
// values -- which beats guessing at them one at a time.
function dumpCycleProperties() {
  if (!getProperty("probeDumpCycleProps")) {
    return;
  }
  writeComment("---- cycle properties ----");
  for (var k in cycle) {
    try {
      writeComment("cycle." + k + " = " + cycle[k]);
    } catch (e) {
      writeComment("cycle." + k + " = <unreadable>");
    }
  }
  writeComment("---- section probe properties ----");
  var names = ["probeWorkOffset", "strategy", "hasParameter"];
  for (var i = 0; i < names.length; ++i) {
    try {
      writeComment("currentSection." + names[i] + " = " + currentSection[names[i]]);
    } catch (e2) {
      writeComment("currentSection." + names[i] + " = <unreadable>");
    }
  }
  writeComment("---- end ----");
}

// Fusion's out-of-position / wrong-size actions. Confirmed by dumping the
// cycle properties: the property only EXISTS when the corresponding box is
// ticked in the operation, and its value is a string such as
// "stop-message". Undefined therefore means the operator did not ask for an
// action, so we report the deviation but let the program continue -- the
// previous behaviour of defaulting to "stop" made the checkbox do nothing.
function isStopAction(action) {
  if (action === undefined) {
    return false;
  }
  return String(action).indexOf("warning") < 0;
}

// Emits the parameter block every probing macro expects. Writing ALL of
// them every time is deliberate: reading an UNDEFINED #<param> is a hard
// gcode error in FluidNC and aborts the controller, so no macro should
// ever have to guess whether a value was set.
function writeProbeParams(extra) {
  dumpCycleProperties();
  var slowFeed = probeFeedSlow ? probeFeedSlow : cycle.feedrate / 4;
  writeBlock("#<_probe_clearance>=" + xyzFormat.format(cycle.probeClearance || 0));
  writeBlock("#<_probe_overtravel>=" + xyzFormat.format(cycle.probeOvertravel || 0));
  writeBlock("#<_probe_feed_fast>=" + feedFormat.format(cycle.feedrate));
  writeBlock("#<_probe_feed_slow>=" + feedFormat.format(slowFeed));
  // Speed for PROTECTED positioning moves inside the macros. Every move
  // made with the probe in the spindle is a G38.3, so this is how fast it
  // travels before it meets anything.
  writeBlock("#<_probe_feed_link>=" + feedFormat.format(probeFeedLink ? probeFeedLink : cycle.feedrate));
  // Nominal stylus radius from the tool library. ProbeInit.nc uses this
  // only as the FALLBACK for #<_probe_yaw> -- the calibrated effective
  // X/Y probe radius -- so probing still works before yaw is calibrated.
  writeBlock("#<_probe_tool_radius>=" + xyzFormat.format(tool.diameter / 2));
  // ABSOLUTE heights straight from Fusion, in the driving offset.
  // Retract Height is referenced to stock top, so it genuinely clears the
  // part. This replaced a RELATIVE lift, which only cleared a feature that
  // happened to be shorter than the lift -- on a tall boss it left the
  // stylus buried in material.
  writeBlock("#<_probe_retract_z>=" + xyzFormat.format(cycle.retract !== undefined ? cycle.retract : 0));
  writeBlock("#<_probe_depth_z>=" + xyzFormat.format(probedSurfaceZ(0)));
  writeBlock("#<_probe_lift>=" + ((extra && extra.lift) ? 1 : 0));
  // Fusion's "Print Results" checkbox. When set, each macro echoes the
  // measured centre, size and deviations to the console via PRINT, which
  // interpolates the parameter values -- so the operator sees the actual
  // numbers rather than only a pass or fail.
  writeBlock("#<_probe_print>=" + (cycle.printResults ? 1 : 0));
  writeBlock("#<_probe_pause>=" + (getProperty("probePauseAfterResults") ? 1 : 0));
  // Fusion's "Probe Geometry" operations are INSPECTION -- they measure a
  // feature during the job and report it, and must not touch the work
  // offset. Its WCS probing operations do the opposite. The two post
  // through exactly the same cycles, so the only way to tell them apart is
  // the section strategy: probe_geometry means measure only.
  var measureOnly = (String(currentSection.strategy) == "probe_geometry");
  writeBlock("#<_probe_set_origin>=" + (measureOnly ? 0 : 1));
  writeBlock("#<_probe_log>=" + (getProperty("probeLogToSD") ? 1 : 0));
  // A numeric program identifier for the log. Gcode parameters hold floats
  // only, so the program NAME cannot survive the trip into the log writer --
  // but Fusion's names are usually numeric ("1001"), so parsing one out of
  // programName gets us something useful. typeof is used rather than a
  // comparison because programName may be undeclared, not merely undefined,
  // and comparing an undeclared identifier throws.
  var progId = 0;
  if (typeof programName != "undefined" && programName) {
    var digits = String(programName).replace(/[^0-9]/g, "");
    progId = digits.length ? parseInt(digits, 10) : 0;
  }
  writeBlock("#<_probe_prog_id>=" + progId);
  // Fusion's inspection tolerances. 0 disables a check. Actions map to
  // 0 = warn only, 1 = alarm and stop the program.
  // WHICH offset the result is written to. Fusion's WCS probing lets you
  // drive the probe from one offset and write the result into another, so
  // this must not be assumed to be the active one. 0 = active offset.
  // The target offset is a SECTION property in Fusion, not a cycle one.
  // Reading cycle.probeWorkOffset silently yielded 0, so every probe
  // wrote to the ACTIVE offset regardless of the WCS Offset set in the
  // operation.
  var wcsTarget = (typeof currentSection.probeWorkOffset != "undefined") ? currentSection.probeWorkOffset : 0;
  writeBlock("#<_probe_wcs>=" + wcsTarget);
  // The NOMINAL position of the feature in that offset. The probed feature
  // is usually NOT at the origin, so the origin is placed such that the
  // found feature lands on these coordinates.
  if (extra && extra.nomX !== undefined) {
    writeBlock("#<_probe_nom_x>=" + xyzFormat.format(extra.nomX));
  }
  if (extra && extra.nomY !== undefined) {
    writeBlock("#<_probe_nom_y>=" + xyzFormat.format(extra.nomY));
  }
  if (extra && extra.nomZ !== undefined) {
    writeBlock("#<_probe_nom_z>=" + xyzFormat.format(extra.nomZ));
  }
  // Fusion exposes explicit enable flags for each tolerance, so use those
  // rather than inferring from the value:
  //   cycle.hasPositionalTolerance / cycle.hasSizeTolerance
  //
  // HALVING IS REQUIRED. The operation field is a +/- figure but the API
  // reports the FULL band: +/-0.2 in the UI comes back as 0.4, and +/-1.00
  // comes back as 2. The macros compare an ABSOLUTE deviation from nominal
  // against this limit, so they need the +/- half, not the whole band.
  // Only the POSITION tolerance is a +/- band that the API reports doubled.
  // The SIZE tolerance comes through as typed, so it must NOT be halved.
  var tolSize = cycle.hasSizeTolerance ? (cycle.toleranceSize || 0) : 0;
  var tolPos  = cycle.hasPositionalTolerance ? (cycle.tolerancePosition || 0) / 2 : 0;
  writeBlock("#<_probe_tol_size>=" + xyzFormat.format(tolSize));
  writeBlock("#<_probe_tol_pos>=" + xyzFormat.format(tolPos));
  writeBlock("#<_probe_action_size>=" + (isStopAction(cycle.wrongSizeAction) ? 1 : 0));
  writeBlock("#<_probe_action_pos>=" + (isStopAction(cycle.outOfPositionAction) ? 1 : 0));
  if (extra && extra.widthX !== undefined) {
    writeBlock("#<_probe_width_x>=" + xyzFormat.format(extra.widthX));
  }
  if (extra && extra.widthY !== undefined) {
    writeBlock("#<_probe_width_y>=" + xyzFormat.format(extra.widthY));
  }
}

// The Z of the surface actually being probed. Fusion's Bottom Height,
// which for a probing cycle is the probing surface. NOT the z handed to
// onCyclePoint -- that is the RETRACT height, and using it set the origin
// high by exactly the retract offset.
function probedSurfaceZ(z) {
  return (cycle.bottom !== undefined) ? cycle.bottom : z;
}

// Rapid is only safe ABOVE the retract height. Anything below it may be
// inside the part, so we drop to retract at rapid and then make a
// PROTECTED move (G38.3) the rest of the way: it stops on contact instead
// of driving the stylus into material. This is what makes plunging into a
// bore or pocket safe when the feature is not quite where CAM thinks.
// Emit a PROTECTED move, always with an explicit feed.
//
// feedOutput is modal, but the macros set their own feeds internally
// (F1000 for the fast touch, F50 for the slow one) and the post cannot see
// that. Left modal, the post would believe F is still the link feed on the
// next operation and suppress it -- so the protected moves would inherit
// F50 from the previous macro and crawl. Resetting forces it out every
// time, which costs one word and removes the whole class of problem.
function protectedMove(words) {
  // Drop any axis word the modal formatter suppressed. If nothing is left
  // the probe is already where we want it, and a bare "G38.3 F..." with no
  // axis word is a gcode error -- so skip the block entirely.
  var parts = [];
  for (var i = 0; i < words.length; ++i) {
    if (words[i]) {
      parts.push(words[i]);
    }
  }
  if (parts.length == 0) {
    return;
  }
  // feedOutput is modal, but the macros set their own feeds internally
  // (F1000 fast, F50 slow) and the post cannot see that. Left modal it
  // would suppress F on the next operation and the move would inherit the
  // leftover F50 and crawl. Reset forces it out every time.
  feedOutput.reset();
  var feed = feedOutput.format(probeFeedLink ? probeFeedLink : cycle.feedrate);
  // Built as ONE pre-joined string rather than writeBlock.apply(): the post
  // engine provides writeBlock as a host function and .apply() on it is not
  // reliably supported, which stops the post loading at all.
  writeBlock("G38.3 " + parts.join(" ") + " " + feed);
}

function safeMoveZ(targetZ) {
  // EVERY Z move made with the probe in the spindle is a PROTECTED move.
  // Not just the part below the retract plane -- the descent from the
  // clearance plane down to retract can still meet a clamp, a fixture or a
  // part that is not where CAM thinks, and a rapid there snaps the stylus.
  // G38.3 stops on contact instead, and unlike G38.2 it does not alarm if
  // nothing is touched, so it behaves as a positioning move when the path
  // is clear.
  //
  // Speed is Fusion's LINK feed rate, which exists precisely for probe
  // positioning moves. Falls back to the cycle feed if the operation did
  // not supply one.
  var retract  = (cycle.retract !== undefined) ? cycle.retract : targetZ;

  if (targetZ >= retract) {
    protectedMove([zOutput.format(targetZ)]);
    return;
  }
  // Two stages so the change of plane is visible in the output, but both
  // are protected.
  protectedMove([zOutput.format(retract)]);
  protectedMove([zOutput.format(targetZ)]);
}

// Stand the probe off from a surface before an edge touch, so the macro's
// clearance+overtravel reach actually spans it. The macro compensates the
// tip radius, but the ball still physically occupies it.
function standoffFor() {
  return (cycle.probeClearance || 0) + tool.diameter / 2;
}

// Single-axis edge probe.
//
// IMPORTANT: the caller passes the APPROACH point -- the ball-centre
// position standing off from the surface by clearance + tip radius -- not
// the surface itself. The surface is derived from it.
//
// For "probing-x" / "probing-y" Fusion's cycle point ALREADY is that
// approach point: on a surface measured at X-82.5 with 10 mm approach and
// a 2.5 mm tip radius, onCyclePoint receives X-95. Offsetting it again
// stood the probe 25 mm off, so it never reached the surface and the probe
// alarmed -- and the origin would have been set 12.5 mm out as well.
//
// For corner cycles Fusion gives the CORNER, so that caller subtracts the
// standoff itself before calling. Either way this function receives an
// approach point and recovers the surface the same way.
// Bring the probe to its starting height for a cycle.
//
// When the macro will LIFT between touches -- an external feature, or an
// internal one with an island -- it descends beside each face itself, and
// the feature centre is NOT safe to descend at: on a boss it is solid
// material, on an island it is the island. Fusion parks the probe at the
// centre, so descending to probing depth here drove the stylus straight
// into the top of the part. Stop at the retract height and let the macro
// place itself.
//
// Without a lift the macro works at depth throughout, and the centre of a
// plain bore or channel is open, so descending is both safe and required.
function moveToCycleStart(z, willLift) {
  if (willLift) {
    safeMoveZ(cycle.retract !== undefined ? cycle.retract : probedSurfaceZ(z));
  } else {
    safeMoveZ(probedSurfaceZ(z));
  }
}

function probeAxisEdge(axis, dir, ax, ay, z) {
  var so = standoffFor();
  var surfaceX = (axis == "X") ? (ax + dir * so) : ax;
  var surfaceY = (axis == "Y") ? (ay + dir * so) : ay;
  writeProbeParams({nomX: surfaceX, nomY: surfaceY});
  // Position in XY FIRST, while still high, and only then descend. The
  // corner cycles offset the approach point from the corner, so traversing
  // at probing depth could drag the stylus through the part.
  protectedMove([xOutput.format(ax), yOutput.format(ay)]);
  if (z !== undefined) {
    safeMoveZ(probedSurfaceZ(z));
  }
  writeBlock("#<_probe_axis_dir>=" + dir);
  runProbeMacro("Probe" + axis + "Edge.nc");
}

function probeZSurface(nz, z) {
  // Fusion leaves the probe at the CLEARANCE PLANE, not at a probing
  // standoff, so the post has to bring it down to the approach point
  // itself. Without this the macro probes clearance+overtravel from
  // wherever Fusion parked it and never reaches the surface.
  //
  // Note we must NOT feed cycle.clearance into #<_probe_clearance> -- that
  // is the absolute retract plane, not a standoff distance. Doing so made
  // the macro expect the surface 65 mm below the start and false-trip the
  // out-of-position alarm.
  var surfaceZ = probedSurfaceZ(z);
  writeProbeParams({nomZ: surfaceZ});
  // sit the probe one approach distance above the surface, then let the
  // macro probe clearance+overtravel downward through it
  safeMoveZ(surfaceZ + (cycle.probeClearance || 0));
  runProbeMacro("ProbeZSurface.nc");
}


// ---------------------------------------------------------------------
// B-AXIS LEVELLING -- the "B level: use this point" operation property.
//
// Two Z touches are enough to find how far the part is tilted about B. A
// face that is flat in the part frame sits at machine height
//
//     Z = za + [w + (X - xa) * sin t] / cos t
//
// with w its nominal height, t the tilt and xa/za the pivot. Differencing
// the two touches removes the pivot AND the part origin -- which matters,
// because nothing has been zeroed yet -- and leaves
//
//     dZ * cos t - dX * sin t = dNominalZ
//
// which the macro solves in closed form. Only the machine X and Z of each
// touch and the two NOMINAL heights appear in it, so:
//   - the two faces may be at different heights, and
//   - tool length, ball radius, the ball riding up a tilted plane and Z
//     pre-travel are all common to both touches and cancel. Nothing here
//     needs calibrating.
//
// The post's job is only to capture the numbers:
//   #5061 / #5063   machine X / Z of the last touch
//   nominal X / Z   this operation's probe point and Bottom Height
// ---------------------------------------------------------------------
var bLevelPointCount = 0;

function bLevelWanted() {
  // A scope:"operation" property arrives on currentSection.properties;
  // getProperty is the fallback. Same pattern as adaptiveFeedGoal.
  if (currentSection.properties && currentSection.properties.bLevelPoint !== undefined) {
    return currentSection.properties.bLevelPoint ? true : false;
  }
  return getProperty("bLevelPoint", false) ? true : false;
}

function bLevelBefore() {
  // #5061/#5063 are machine coordinates and the macro reasons in the
  // machine frame, so the touches must not be made through TCP. Routed
  // through setTCP rather than a bare M129 so state.tcpIsActive stays
  // honest and a later section turns TCP back on for itself.
  //
  // Forced, because M128/M129 is modal in the CONTROLLER while the post
  // merely assumes it starts off. Run after a program that ended with TCP
  // on and an unforced call writes nothing, so the touches would go
  // through the kinematics and #5061/#5063 would not mean what the macro
  // thinks they mean.
  setTCP(false, true);
}

function bLevelAfter(nomX, nomZ) {
  var n = (bLevelPointCount % 2) + 1; // 1, 2, 1, 2, ... -- pairs in order
  ++bLevelPointCount;
  writeComment("B level point " + n + " captured");
  writeBlock("#<_bl_x" + n + ">=#5061");
  writeBlock("#<_bl_y" + n + ">=#5062");
  writeBlock("#<_bl_z" + n + ">=#5063");
  writeBlock("#<_bl_nx" + n + ">=" + xyzFormat.format(nomX));
  writeBlock("#<_bl_nz" + n + ">=" + xyzFormat.format(nomZ));
  if (n == 1) {
    return;
  }
  writeBlock("#<_bl_mode>=1");
  writeBlock("#<_bl_wcs>=" + B_LEVEL_OFFSET);
  runProbeMacro("ProbeBLevel.nc");
  // The macro has just changed the offset's B component WITHOUT moving
  // the machine, so the work B angle is no longer the number bOutput last
  // wrote. Without this the next indexing move can be suppressed as a
  // no-change and the part never gets rotated.
  forceABC();
}

function probeChannel(axis, width, withIsland, nx, ny, z) {
  writeProbeParams({
    widthX: (axis == "X") ? width : undefined,
    widthY: (axis == "Y") ? width : undefined,
    lift: withIsland,
    nomX: nx, nomY: ny
  });
  moveToCycleStart(z, withIsland);
  runProbeMacro("Probe" + axis + "Channel.nc");
}

function probeWall(axis, width, nx, ny, z) {
  // A web is external, so the probe must clear the top of the part while
  // moving out past each face -- the lift is mandatory, not optional.
  writeProbeParams({
    widthX: (axis == "X") ? width : undefined,
    widthY: (axis == "Y") ? width : undefined,
    lift: true,
    nomX: nx, nomY: ny
  });
  moveToCycleStart(z, true);
  runProbeMacro("Probe" + axis + "Wall.nc");
}

function probeInnerXY(widthX, widthY, withIsland, nx, ny, z) {
  writeProbeParams({
    widthX: widthX,
    widthY: widthY,
    lift: withIsland,
    nomX: nx, nomY: ny
  });
  moveToCycleStart(z, withIsland);
  runProbeMacro("ProbeInnerXY.nc");
}

// The three touch angles come from FUSION. Autodesk's partial-circle
// cycles carry them as partialCircleAngleA/B/C -- the same three angles
// Renishaw's 9823 macro takes -- and they map directly onto the three
// points the macro solves the circle through.
//
// There is deliberately NO fallback. Only Fusion knows which part of the
// arc is reachable, so substituting a default here would drive the stylus
// at whatever the post happened to be set to rather than along the arc the
// operation planned. Failing to post is the safe outcome.
function writePartialAngles() {
  var a = cycle.partialCircleAngleA;
  var b = cycle.partialCircleAngleB;
  var c = cycle.partialCircleAngleC;
  if (a === undefined || b === undefined || c === undefined) {
    error(localize("This partial-circle operation did not supply the three probe "
      + "angles (partialCircleAngleA/B/C). Without them the probe path cannot be "
      + "generated safely."));
    return;
  }
  writeBlock("#<_probe_angle_1>=" + xyzFormat.format(a));
  writeBlock("#<_probe_angle_2>=" + xyzFormat.format(b));
  writeBlock("#<_probe_angle_3>=" + xyzFormat.format(c));
}

// Partial BOSS. External, so the lift is mandatory -- the nominal centre is
// solid material and cannot be traversed. Differs from the partial hole in
// the sign of the radius correction as well as the motion.
function probePartialBoss(dia, nx, ny, z) {
  writeProbeParams({widthX: dia, widthY: dia, lift: true, nomX: nx, nomY: ny});
  writeBlock("#<_probe_diameter>=" + xyzFormat.format(dia));
  writePartialAngles();
  moveToCycleStart(z, true);
  runProbeMacro("ProbePartialBoss.nc");
}

function probePartialHole(dia, withIsland, nx, ny, z) {
  writeProbeParams({widthX: dia, widthY: dia, lift: withIsland, nomX: nx, nomY: ny});
  writeBlock("#<_probe_diameter>=" + xyzFormat.format(dia));
  writePartialAngles();
  moveToCycleStart(z, withIsland);
  runProbeMacro("ProbePartialHole.nc");
}

function probeOuterXY(widthX, widthY, nx, ny, z) {
  // A boss ALWAYS needs a lift -- the probe has to get out past each face
  // and back down beside it without dragging over the top.
  writeProbeParams({widthX: widthX, widthY: widthY, lift: true, nomX: nx, nomY: ny});
  moveToCycleStart(z, true);
  runProbeMacro("ProbeOuterXY.nc");
}

function onCyclePoint(x, y, z) {
  if (!isProbeOperation()) {
    expandCyclePoint(x, y, z);
    return;
  }

  // Caught at post time rather than letting the tick do nothing: the
  // levelling maths needs a Z touch, so only a surface cycle can feed it.
  if (bLevelWanted() && cycleType != "probing-z") {
    error(localize("'B level: use this point' only works on a Probe Geometry - Surface (Z) cycle. This operation posts as " + cycleType + "."));
    return;
  }

  // Circular features carry their size in width1, NOT in a "diameter"
  // property -- confirmed from a cycle-property dump, where cycle.diameter
  // does not exist on any cycle. Reading it gave undefined and the format
  // call then failed with "Value is not a number".
  var dia = (cycle.diameter !== undefined) ? cycle.diameter : cycle.width1;
  // width1 is the primary size; width2 only exists on rectangular features.
  // Single-axis cycles (channel, wall) carry their one dimension in width1
  // regardless of axis, so fall back to it rather than emitting undefined.
  var wx  = cycle.width1;
  var wy  = (cycle.width2 !== undefined) ? cycle.width2 : cycle.width1;

  switch (cycleType) {
  // ---- single axis ------------------------------------------------
  case "probing-x":
    writeComment("Probing X edge");
    probeAxisEdge("X", (cycle.approach1 == "positive") ? 1 : -1, x, y, z);
    break;
  case "probing-y":
    writeComment("Probing Y edge");
    probeAxisEdge("Y", (cycle.approach1 == "positive") ? 1 : -1, x, y, z);
    break;
  case "probing-z":
    writeComment("Probing Z surface");
    if (bLevelWanted()) {
      bLevelBefore();
      probeZSurface(z, z);
      // x is the probe point in the driving offset; probedSurfaceZ(z) is
      // Fusion's Bottom Height, i.e. this face's nominal height in it.
      bLevelAfter(x, probedSurfaceZ(z));
    } else {
      probeZSurface(z, z);
    }
    break;

  // ---- corners ----------------------------------------------------
  case "probing-xy-outer-corner":
  case "probing-xy-inner-corner":
    // Two single-axis touches: reposition to be aligned with the corner
    // on one axis, offset by the standoff on the other, probe X; then
    // the mirror image for Y. Worth checking against Fusion's own
    // simulation before cutting -- the exact approach-point geometry
    // Fusion assumes isn't something I could verify here.
    writeComment("Probing XY corner (" + cycleType + ")");
    var dirX = (cycle.approach1 == "positive") ? 1 : -1;
    var dirY = (cycle.approach2 == "positive") ? 1 : -1;
    var standoff = cycle.probeClearance + tool.diameter / 2;
    probeAxisEdge("X", dirX, x - dirX * standoff, y, z);
    probeAxisEdge("Y", dirY, x, y - dirY * standoff, z);
    writeComment("XY corner probed");
    break;

  // ---- channels / slots -------------------------------------------
  case "probing-x-channel":
    writeComment("Probing X channel");
    probeChannel("X", wx, false, x, y, z);
    break;
  case "probing-x-channel-with-island":
    writeComment("Probing X channel with island");
    probeChannel("X", wx, true, x, y, z);
    break;
  case "probing-y-channel":
    writeComment("Probing Y channel");
    probeChannel("Y", wy, false, x, y, z);
    break;
  case "probing-y-channel-with-island":
    writeComment("Probing Y channel with island");
    probeChannel("Y", wy, true, x, y, z);
    break;

  // ---- webs: two OUTSIDE walls measured across one axis --------------
  // The external counterpart of a channel -- e.g. probing both sides of
  // a part or a rib to find its centreline in one axis.
  // Fusion calls these WALL cycles: the two OUTSIDE faces either side of a
  // part, the external counterpart of a channel. I originally guessed at
  // "-web" from Renishaw terminology; the real string is "-wall". Both are
  // listed since an alias costs nothing and a missed cycle silently skips.
  case "probing-x-wall":
  case "probing-x-web":
    writeComment("Probing X wall pair");
    probeWall("X", wx, x, y, z);
    break;
  case "probing-y-wall":
  case "probing-y-web":
    writeComment("Probing Y wall pair");
    probeWall("Y", wy, x, y, z);
    break;

  // ---- circular bores / bosses ------------------------------------
  // A circle is just an inner/outer feature whose X and Y sizes are
  // both the diameter, so these share the rectangular macros.
  case "probing-xy-circular-hole":
    writeComment("Probing circular hole");
    probeInnerXY(dia, dia, false, x, y, z);
    break;
  case "probing-xy-circular-hole-with-island":
    writeComment("Probing circular hole with island");
    probeInnerXY(dia, dia, true, x, y, z);
    break;
  case "probing-xy-circular-boss":
    writeComment("Probing circular boss");
    probeOuterXY(dia, dia, x, y, z);
    break;

  // ---- rectangular pockets / bosses -------------------------------
  case "probing-xy-rectangular-hole":
    writeComment("Probing rectangular hole");
    probeInnerXY(wx, wy, false, x, y, z);
    break;
  case "probing-xy-rectangular-hole-with-island":
    writeComment("Probing rectangular hole with island");
    probeInnerXY(wx, wy, true, x, y, z);
    break;
  case "probing-xy-rectangular-boss":
    writeComment("Probing rectangular boss");
    probeOuterXY(wx, wy, x, y, z);
    break;

  // ---- deliberately not implemented -------------------------------
  // "partial" variants exist precisely because the full circle ISN'T
  // reachable, so probing the four cardinal points would drive the
  // stylus into material. They need the angular positions Fusion
  // assumes, which I can't verify, so they are refused rather than
  // guessed at.
  // ---- partial circular holes -------------------------------------
  // Three touches on the reachable arc, solved as the circle through
  // three points. The angles come from the post properties below --
  // they MUST all lie inside the arc you can actually reach, or the
  // stylus will be driven into material.
  case "probing-xy-circular-partial-hole":
  case "probing-xy-circular-partial-hole-with-island":
    writeComment("Probing partial circular hole (3 point)");
    probePartialHole(dia, cycleType.indexOf("island") >= 0, x, y, z);
    break;

  // Partial BOSS: three touches on the reachable arc, probing INWARD from
  // outside. The tip radius is SUBTRACTED rather than added when recovering
  // the diameter, and the probe must lift over the boss between touches
  // because its centre is solid material.
  case "probing-xy-circular-partial-boss":
    writeComment("Probing partial circular boss (3 point)");
    probePartialBoss(dia, x, y, z);
    break;

  // Angle / coordinate-rotation cycles are intentionally out of scope.
  case "probing-x-plane-angle":
  case "probing-y-plane-angle":
  case "probing-xy-plane-angle":
    error(localize("Coordinate-rotation probing (" + cycleType + ") is not supported by this post."));
    break;

  default:
    var msg = "Probe cycle '" + cycleType + "' is not implemented in this post -- skipping.";
    writeComment(msg);
    warning(msg);
    break;
  }
}

function forceCircular(plane) {
  switch (plane) {
  case PLANE_XY:
    xOutput.reset();
    yOutput.reset();
    iOutput.reset();
    jOutput.reset();
    break;
  case PLANE_ZX:
    zOutput.reset();
    xOutput.reset();
    kOutput.reset();
    iOutput.reset();
    break;
  case PLANE_YZ:
    yOutput.reset();
    zOutput.reset();
    jOutput.reset();
    kOutput.reset();
    break;
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  updateAdaptiveFeedForMovement();
  // one of X/Y and I/J are required and likewise

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (isHelical()) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), iOutput.format(cx - start.x), jOutput.format(cy - start.y), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), zOutput.format(z), iOutput.format(cx - start.x), kOutput.format(cz - start.z), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), yOutput.format(y), jOutput.format(cy - start.y), kOutput.format(cz - start.z), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else {
    switch (getCircularPlane()) {
    case PLANE_XY:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(17), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x), jOutput.format(cy - start.y), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(18), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x), kOutput.format(cz - start.z), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      forceCircular(getCircularPlane());
      writeBlock(gPlaneModal.format(19), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y), kOutput.format(cz - start.z), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var mapCommand = {
  COMMAND_STOP                    : 0,
  COMMAND_END                     : 2,
  COMMAND_SPINDLE_CLOCKWISE       : 3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE: 4,
  COMMAND_STOP_SPINDLE            : 5
};

function onCommand(command) {
  switch (command) {
  case COMMAND_COOLANT_OFF:
    setCoolant(COOLANT_OFF);
    return;
  case COMMAND_COOLANT_ON:
    setCoolant(tool.coolant);
    return;
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    forceCoolant = true;
    return;
  case COMMAND_OPTIONAL_STOP:
    writeBlock(mFormat.format(1));
    forceSpindleSpeed = true;
    forceCoolant = true;
    return;
  case COMMAND_START_SPINDLE:
    forceSpindleSpeed = false;
    writeBlock(sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4));
    return;
  case COMMAND_LOAD_TOOL:
    // mapTool() is identity on an ATC machine. On one without a changer it
    // renumbers clear of the rack so the firmware takes its manual path.
    var postedTool = mapTool(tool.number);
    // T100 is the known-gauge-length reference/calibration tool -- it
    // doesn't have a comparable "expected" gauge length from Fusion in the
    // same sense as a real cutting tool, so it's excluded here.
    if (postedTool != GAUGE_SETTER_TOOL) {
      if (getProperty("outputToolGaugeVariable")) {
        writeBlock("#<_fusion_tool_gauge>=" + xyzFormat.format(getBodyLength(tool)));
      }
    }
    if (getProperty("outputToolChange")) {
      // Anything outside the rack is a tool the operator has to fetch and
      // fit, so say which one, and which holder it lives in, right where
      // they will be standing when the machine stops for it.
      if (atcSlotIndex(postedTool) < 0) {
        writeComment("--- MANUAL TOOL CHANGE ---");
        writeToolSummary(tool, "  ");
      }
      writeToolBlock("T" + toolFormat.format(postedTool), mFormat.format(6));
      // Replay the ATC's real rack path into the simulation stream so
      // collisions during the change are visible. Writes nothing to the NC
      // file, and is a no-op when not simulating. Fed the POSTED number, so
      // a renumbered tool draws the manual sequence instead of a rack pick.
      atcSimulateToolChange(postedTool, getBodyLength(tool));
    } else {
      machineSimulation({mode:TOOLCHANGE}); // simulate tool change
    }
    writeComment(tool.comment);
    if (postedTool != GAUGE_SETTER_TOOL && getProperty("outputToolLengthCheck")) {
      // Compares #<_fusion_tool_gauge> above against whatever the machine
      // has recorded (a mastered rack tool) or just measured (a manual
      // tool) for the tool now in the spindle -- see Macros/CheckToolGauge.nc
      writeBlock("$SD/Run=CheckToolGauge.nc");
    }
    return;
  case COMMAND_LOCK_MULTI_AXIS:
  case COMMAND_UNLOCK_MULTI_AXIS:
    // The B axis has no clamp. Swallowed here so the generic mapCommand
    // lookup at the end of this function does not emit anything for them.
    return;
  case COMMAND_BREAK_CONTROL:
    writeBlock("$SD/Run=BreakDetection.nc");
    return;
  case COMMAND_TOOL_MEASURE:
    // Fires from a Manual NC "Measure Tool" step in the Fusion timeline.
    // Re-probes/re-stores the gauge length of whatever tool is currently
    // in the spindle -- a no-op (with a logged error) if it's not a rack
    // tool or isn't the tool actually loaded. See atc_custom.cpp's M101.
    writeBlock("M101 T" + toolFormat.format(mapTool(tool.number)));
    writeComment(localize("MEASURE TOOL " + mapTool(tool.number)));
    return;
  }

  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  if (currentSection.isMultiAxis()) {
    writeBlock(gFeedModeModal.format(94)); // inverse time feed off
  }
  writeBlock(gPlaneModal.format(17));
  if (!isLastSection()) {
    if (getNextSection().getTool().coolant != tool.coolant) {
      setCoolant(COOLANT_OFF);
    }
    if (tool.breakControl && isToolChangeNeeded(getNextSection(), getProperty("toolAsName") ? "description" : "number")) {
      onCommand(COMMAND_BREAK_CONTROL);
    }
  }
  forceAny();
}

function writeProgramEnd() {
  setCoolant(COOLANT_OFF);
  writeRetract(Z);
  if (getSetting("retract.homeXY.onProgramEnd", false)) {
    writeRetract(settings.retract.homeXY.onProgramEnd);
  }
  // Cancel RPCP before the B axis is sent home, and before the program ends.
  //
  // Two reasons. The machine is left in a known state for jogging, the
  // toolsetter and the ATC macros, all of which work in machine coordinates
  // -- M128/M129 is modal in the controller and nothing else was turning it
  // off, so a multi-axis job used to finish with it still on.
  //
  // And the reset below is a bare rotation this way. With TCP still active,
  // sending B to 0 holds the tool tip still relative to the part, so the
  // linear axes move as well -- an unasked-for XYZ move at the end of a job.
  // Off first, and B goes home while nothing else does.
  //
  // Unforced: a 3-axis program never turned it on, and writeProgramStart
  // has already asserted it off, so there is nothing to cancel.
  setTCP(false);
  forceWorkPlane();
  setWorkPlane(new Vector(0, 0, 0)); // reset working plane
  onCommand(COMMAND_STOP_SPINDLE);
  writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  if (isRedirecting()) {
    closeRedirection();
  }
}

function onClose() {
  optionalSection = false;
  // A lone tick captures a point and then never runs the macro, so the
  // part silently stays unlevelled. Say so at post time instead.
  if (bLevelPointCount % 2) {
    error(localize("B level: an odd number of points is ticked. Each levelling pass needs exactly two."));
  }
  // Don't leave adaptive feed control active for whatever runs after this
  // job (manual MDI moves, the next unrelated program, etc.).
  currentAdaptiveFeedGoal = 0;
  setAdaptiveFeed(false);
  writeln("");
  writeProgramEnd();
}

// >>>>> INCLUDED FROM include_files/commonFunctions.cpi
// internal variables, do not change
var receivedMachineConfiguration;
var tcp = {isSupportedByControl:getSetting("supportsTCP", true), isSupportedByMachine:false, isSupportedByOperation:false};
var state = {
  retractedX              : false, // specifies that the machine has been retracted in X
  retractedY              : false, // specifies that the machine has been retracted in Y
  retractedZ              : false, // specifies that the machine has been retracted in Z
  tcpIsActive             : false, // specifies that TCP is currently active
  twpIsActive             : false, // specifies that TWP is currently active
  lengthCompensationActive: !getSetting("outputToolLengthCompensation", true), // specifies that tool length compensation is active
  mainState               : true // specifies the current context of the state (true = main, false = optional)
};
var validateLengthCompensation = getSetting("outputToolLengthCompensation", true); // disable validation when outputToolLengthCompensation is disabled
var multiAxisFeedrate;
var sequenceNumber;
var optionalSection = false;
// ---------------------------------------------------------------------
// Adaptive feed (M52) state.
//
// currentAdaptiveFeedGoal is this operation's target, set in onSection.
// adaptiveFeedActive tracks whether M52 is currently ENABLED in the
// output stream. Adaptive feed is deliberately suppressed during every
// non-cutting move -- rapids, lead in/out, plunges, ramps and link moves
// -- and only enabled once actual cutting starts. Without this, torque
// reads ~0 during an air move, so the goal-seeking controller ramps the
// override UP chasing its target and the tool then enters the cut at a
// high override. Re-enabling only on real cutting moves avoids that.
var currentAdaptiveFeedGoal = 0;
var adaptiveFeedActive = false;

function setAdaptiveFeed(on) {
  if (on == adaptiveFeedActive) {
    return; // no change, don't spam M52
  }
  writeBlock("M52 P" + (on ? xyzFormat.format(currentAdaptiveFeedGoal / 100) : "0"));
  adaptiveFeedActive = on;
}

// Called at the top of every motion handler. `movement` is the kernel's
// current move classification.
function updateAdaptiveFeedForMovement() {
  if (currentAdaptiveFeedGoal <= 0) {
    return; // goal-seeking off for this operation entirely
  }
  var isCutting = (movement == MOVEMENT_CUTTING) || (movement == MOVEMENT_FINISH_CUTTING);
  setAdaptiveFeed(isCutting);
}
var currentWorkOffset;
var forceSpindleSpeed = false;
var operationNeedsSafeStart = false; // used to convert blocks to optional for safeStartAllOperations

function activateMachine() {
  // disable unsupported rotary axes output
  if (!machineConfiguration.isMachineCoordinate(0) && (typeof aOutput != "undefined")) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1) && (typeof bOutput != "undefined")) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2) && (typeof cOutput != "undefined")) {
    cOutput.disable();
  }

  // setup usage of useTiltedWorkplane
  settings.workPlaneMethod.useTiltedWorkplane = getProperty("useTiltedWorkplane") != undefined ? getProperty("useTiltedWorkplane") :
    getSetting("workPlaneMethod.useTiltedWorkplane", false);
  settings.workPlaneMethod.useABCPrepositioning = getSetting("workPlaneMethod.useABCPrepositioning", true);

  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // don't need to modify any settings for 3-axis machines
  }

  // identify if any of the rotary axes has TCP enabled
  var axes = [machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW()];
  tcp.isSupportedByMachine = axes.some(function(axis) {return axis.isEnabled() && axis.isTCPEnabled();}); // true if TCP is enabled on any rotary axis
  if (tcp.isSupportedByMachine) {
    bufferRotaryMoves = false; // disable bufferRotaryMoves if TCP is enabled on any rotary axis
  }

  // save multi-axis feedrate settings from machine configuration
  var mode = machineConfiguration.getMultiAxisFeedrateMode();
  var type = mode == FEED_INVERSE_TIME ? machineConfiguration.getMultiAxisFeedrateInverseTimeUnits() :
    (mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateDPMType() : DPM_STANDARD);
  multiAxisFeedrate = {
    mode     : mode,
    maximum  : machineConfiguration.getMultiAxisFeedrateMaximum(),
    type     : type,
    tolerance: mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateOutputTolerance() : 0,
    bpwRatio : mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateBpwRatio() : 1
  };

  // setup of retract/reconfigure  TAG: Only needed until post kernel supports these machine config settings
  if (receivedMachineConfiguration && machineConfiguration.performRewinds()) {
    safeRetractDistance = machineConfiguration.getSafeRetractDistance();
    safePlungeFeed = machineConfiguration.getSafePlungeFeedrate();
    safeRetractFeed = machineConfiguration.getSafeRetractFeedrate();
  }
  if (typeof safeRetractDistance == "number" && getProperty("safeRetractDistance") != undefined && getProperty("safeRetractDistance") != 0) {
    safeRetractDistance = getProperty("safeRetractDistance");
  }

  if (revision >= 50294) {
    activateAutoPolarMode({tolerance:tolerance / 2, optimizeType:OPTIMIZE_AXIS, expandCycles:getSetting("polarCycleExpandMode", EXPAND_ALL)});
  }

  if (machineConfiguration.isHeadConfiguration() && getSetting("workPlaneMethod.compensateToolLength", false)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var section = getSection(i);
      if (section.isMultiAxis()) {
        machineConfiguration.setToolLength(getBodyLength(section.getTool())); // define the tool length for head adjustments
        section.optimizeMachineAnglesByMachine(machineConfiguration, OPTIMIZE_AXIS);
      }
    }
  } else {
    optimizeMachineAngles2(OPTIMIZE_AXIS);
  }
}

function getBodyLength(tool) {
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (tool.number == section.getTool().number) {
      if (section.hasParameter("operation:tool_assemblyGaugeLength")) { // For Fusion
        return section.getParameter("operation:tool_assemblyGaugeLength", tool.bodyLength + tool.holderLength);
      } else { // Legacy products
        return section.getParameter("operation:tool_overallLength", tool.bodyLength + tool.holderLength);
      }
    }
  }
  return tool.bodyLength + tool.holderLength;
}

// FluidNC's feed rate modes are G93 and G94 -- there is no G95, and no
// parametric #-variable feed scheme, so this is just the number.
function getFeed(f) {
  return feedOutput.format(f);
}

function validateCommonParameters() {
  validateToolData();
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (getSection(0).workOffset == 0 && section.workOffset > 0) {
      if (!(typeof wcsDefinitions != "undefined" && wcsDefinitions.useZeroOffset)) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
      }
    }
    if (section.isMultiAxis()) {
      if (!section.isOptimizedForMachine() &&
        (!getSetting("workPlaneMethod.useTiltedWorkplane", false) || !getSetting("supportsToolVectorOutput", false))) {
        error(localize("This postprocessor requires a machine configuration for 5-axis simultaneous toolpath."));
      }
      if (machineConfiguration.getMultiAxisFeedrateMode() == FEED_INVERSE_TIME && !getSetting("supportsInverseTimeFeed", true)) {
        error(localize("This postprocessor does not support inverse time feedrates."));
      }
      if (getSetting("supportsToolVectorOutput", false) && !tcp.isSupportedByControl) {
        error(localize("Incompatible postprocessor settings detected." + EOL +
        "Setting 'supportsToolVectorOutput' requires setting 'supportsTCP' to be enabled as well."));
      }
    }
  }
  if (!tcp.isSupportedByControl && tcp.isSupportedByMachine) {
    error(localize("The machine configuration has TCP enabled which is not supported by this postprocessor."));
  }
  if (getProperty("safePositionMethod") == "clearanceHeight") {
    var msg = "-Attention- Property 'Safe Retracts' is set to 'Clearance Height'." + EOL +
      "Ensure the clearance height will clear the part and or fixtures." + EOL +
      "Raise the Z-axis to a safe height before starting the program.";
    warning(msg);
    writeComment(msg);
  }
}

function validateToolData() {
  var _default = 99999;
  var _maximumSpindleRPM = machineConfiguration.getMaximumSpindleSpeed() > 0 ? machineConfiguration.getMaximumSpindleSpeed() :
    settings.maximumSpindleRPM == undefined ? _default : settings.maximumSpindleRPM;
  var _maximumToolNumber = machineConfiguration.isReceived() && machineConfiguration.getNumberOfTools() > 0 ? machineConfiguration.getNumberOfTools() :
    settings.maximumToolNumber == undefined ? _default : settings.maximumToolNumber;
  var _maximumToolLengthOffset = settings.maximumToolLengthOffset == undefined ? _default : settings.maximumToolLengthOffset;
  var _maximumToolDiameterOffset = settings.maximumToolDiameterOffset == undefined ? _default : settings.maximumToolDiameterOffset;

  var header = ["Detected maximum values are out of range.", "Maximum values:"];
  var warnings = {
    toolNumber    : {msg:"Tool number value exceeds the maximum value for tool: " + EOL, max:" Tool number: " + _maximumToolNumber, values:[]},
    lengthOffset  : {msg:"Tool length offset value exceeds the maximum value for tool: " + EOL, max:" Tool length offset: " + _maximumToolLengthOffset, values:[]},
    diameterOffset: {msg:"Tool diameter offset value exceeds the maximum value for tool: " + EOL, max:" Tool diameter offset: " + _maximumToolDiameterOffset, values:[]},
    spindleSpeed  : {msg:"Spindle speed exceeds the maximum value for operation: " + EOL, max:" Spindle speed: " + _maximumSpindleRPM, values:[]}
  };

  var toolIds = [];
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (toolIds.indexOf(section.getTool().getToolId()) === -1) { // loops only through sections which have a different tool ID
      var toolNumber = section.getTool().number;
      var lengthOffset = section.getTool().lengthOffset;
      var diameterOffset = section.getTool().diameterOffset;
      var comment = section.getParameter("operation-comment", "");

      if (toolNumber > _maximumToolNumber && !getProperty("toolAsName")) {
        warnings.toolNumber.values.push(SP + toolNumber + EOL);
      }
      if (lengthOffset > _maximumToolLengthOffset) {
        warnings.lengthOffset.values.push(SP + "Tool " + toolNumber + " (" + comment + "," + " Length offset: " + lengthOffset + ")" + EOL);
      }
      if (diameterOffset > _maximumToolDiameterOffset) {
        warnings.diameterOffset.values.push(SP + "Tool " + toolNumber + " (" + comment + "," + " Diameter offset: " + diameterOffset + ")" + EOL);
      }
      toolIds.push(section.getTool().getToolId());
    }
    // loop through all sections regardless of tool id for idenitfying spindle speeds

    // identify if movement ramp is used in current toolpath, use ramp spindle speed for comparisons
    var ramp = section.getMovements() & ((1 << MOVEMENT_RAMP) | (1 << MOVEMENT_RAMP_ZIG_ZAG) | (1 << MOVEMENT_RAMP_PROFILE) | (1 << MOVEMENT_RAMP_HELIX));
    var _sectionSpindleSpeed = Math.max(section.getTool().spindleRPM, ramp ? section.getTool().rampingSpindleRPM : 0, 0);
    if (_sectionSpindleSpeed > _maximumSpindleRPM) {
      warnings.spindleSpeed.values.push(SP + section.getParameter("operation-comment", "") + " (" + _sectionSpindleSpeed + " RPM" + ")" + EOL);
    }
  }

  // sort lists by tool number
  warnings.toolNumber.values.sort(function(a, b) {return a - b;});
  warnings.lengthOffset.values.sort(function(a, b) {return a.localeCompare(b);});
  warnings.diameterOffset.values.sort(function(a, b) {return a.localeCompare(b);});

  var warningMessages = [];
  for (var key in warnings) {
    if (warnings[key].values != "") {
      header.push(warnings[key].max); // add affected max values to the header
      warningMessages.push(warnings[key].msg + warnings[key].values.join(""));
    }
  }
  if (warningMessages.length != 0) {
    warningMessages.unshift(header.join(EOL) + EOL);
    warning(warningMessages.join(EOL));
  }
}

function forceFeed() {
  currentFeedId = undefined;
  feedOutput.reset();
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  forceFeed();
}

/**
  Writes the specified block.
*/
function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  var prefix = getSetting("sequenceNumberPrefix", "N");
  var suffix = getSetting("writeBlockSuffix", "");
  if ((optionalSection || skipBlocks) && !getSetting("supportsOptionalBlocks", true)) {
    error(localize("Optional blocks are not supported by this post."));
  }
  if (getProperty("showSequenceNumbers") == "true") {
    if (sequenceNumber == undefined || sequenceNumber >= settings.maximumSequenceNumber) {
      sequenceNumber = getProperty("sequenceNumberStart");
    }
    if (optionalSection || skipBlocks) {
      writeWords2("/", prefix + sequenceNumber, text + suffix);
    } else {
      writeWords2(prefix + sequenceNumber, text + suffix);
    }
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    if (optionalSection || skipBlocks) {
      writeWords2("/", text + suffix);
    } else {
      writeWords(text + suffix);
    }
  }
}

validate(settings.comments, "Setting 'comments' is required but not defined.");
function formatComment(text) {
  var prefix = settings.comments.prefix;
  var suffix = settings.comments.suffix;
  var _permittedCommentChars = settings.comments.permittedCommentChars == undefined ? "" : settings.comments.permittedCommentChars;
  switch (settings.comments.outputFormat) {
  case "upperCase":
    text = text.toUpperCase();
    _permittedCommentChars = _permittedCommentChars.toUpperCase();
    break;
  case "lowerCase":
    text = text.toLowerCase();
    _permittedCommentChars = _permittedCommentChars.toLowerCase();
    break;
  case "ignoreCase":
    _permittedCommentChars = _permittedCommentChars.toUpperCase() + _permittedCommentChars.toLowerCase();
    break;
  default:
    error(localize("Unsupported option specified for setting 'comments.outputFormat'."));
  }
  if (_permittedCommentChars != "") {
    text = filterText(String(text), _permittedCommentChars);
  }
  text = String(text).substring(0, settings.comments.maximumLineLength - prefix.length - suffix.length);
  return text != "" ? prefix + text + suffix : "";
}

/**
  Output a comment.
*/
function writeComment(text) {
  if (!text) {
    return;
  }
  var comments = String(text).split(/\r?\n/);
  for (comment in comments) {
    var _comment = formatComment(comments[comment]);
    if (_comment) {
      if (getSetting("comments.showSequenceNumbers", false)) {
        writeBlock(_comment);
      } else {
        writeln(_comment);
      }
    }
  }
}

function onComment(text) {
  writeComment(text);
}

/**
  Writes the specified block - used for tool changes only.
*/
function writeToolBlock() {
  var show = getProperty("showSequenceNumbers");
  setProperty("showSequenceNumbers", (show == "true" || show == "toolChange") ? "true" : "false");
  writeBlock(arguments);
  setProperty("showSequenceNumbers", show);
  machineSimulation({/*x:toPreciseUnit(200, MM), y:toPreciseUnit(200, MM), coordinates:MACHINE,*/ mode:TOOLCHANGE}); // move machineSimulation to a tool change position
}

var skipBlocks = false;
var initialState = JSON.parse(JSON.stringify(state)); // save initial state
var optionalState = JSON.parse(JSON.stringify(state));
var saveCurrentSectionId = undefined;
function writeStartBlocks(isRequired, code) {
  var saveSkipBlocks = skipBlocks;
  var saveMainState = state; // save main state

  if (!isRequired) {
    if (!getProperty("safeStartAllOperations", false)) {
      return; // when safeStartAllOperations is disabled, dont output code and return
    }
    if (saveCurrentSectionId != getCurrentSectionId()) {
      saveCurrentSectionId = getCurrentSectionId();
      forceModals(); // force all modal variables when entering a new section
      optionalState = Object.create(initialState); // reset optionalState to initialState when entering a new section
    }
    skipBlocks = true; // if values are not required, but safeStartAllOperations is enabled - write following blocks as optional
    state = optionalState; // set state to optionalState if skipBlocks is true
    state.mainState = false;
  }
  code(); // writes out the code which is passed to this function as an argument

  state = saveMainState; // restore main state
  skipBlocks = saveSkipBlocks; // restore skipBlocks value
}

// FluidNC has no cutter radius compensation. G41 and G42 are not in its
// gcode parser at all, and G40 is accepted only as a no-op -- "Not required
// since cutter radius compensation is always disabled. Only here to support
// G40 commands that often appear in g-code program headers". So this refuses
// outright, and records no pending state, which is what lets every
// compensation branch below go.
function onRadiusCompensation() {
  if (radiusCompensation >= 0) {
    error(localize("Radius compensation is not supported: FluidNC has no G41/G42. " +
      "Set the operation's compensation type to 'In computer'."));
  }
}

function onPassThrough(text) {
  var commands = String(text).split(",");
  for (text in commands) {
    writeBlock(commands[text]);
  }
}

function forceModals() {
  if (arguments.length == 0) { // reset all modal variables listed below
    var modals = [
      "gMotionModal",
      "gPlaneModal",
      "gAbsIncModal",
      "gFeedModeModal",
      "feedOutput"
    ];
    for (var i = 0; i < modals.length; ++i) {
      if (typeof this[modals[i]] != "undefined") {
        this[modals[i]].reset();
      }
    }
  } else {
    for (var i in arguments) {
      arguments[i].reset(); // only reset the modal variable passed to this function
    }
  }
}

/** Helper function to be able to use a default value for settings which do not exist. */
function getSetting(setting, defaultValue) {
  var result = defaultValue;
  var keys = setting.split(".");
  var obj = settings;
  for (var i in keys) {
    if (obj[keys[i]] != undefined) { // setting does exist
      result = obj[keys[i]];
      if (typeof [keys[i]] === "object") {
        obj = obj[keys[i]];
        continue;
      }
    } else { // setting does not exist, use default value
      if (defaultValue != undefined) {
        result = defaultValue;
      } else {
        error("Setting '" + keys[i] + "' has no default value and/or does not exist.");
        return undefined;
      }
    }
  }
  return result;
}

function getForwardDirection(_section) {
  var forward = undefined;
  var _optimizeType = settings.workPlaneMethod && settings.workPlaneMethod.optimizeType;
  if (_section.isMultiAxis()) {
    forward = _section.workPlane.forward;
  } else if (!getSetting("workPlaneMethod.useTiltedWorkplane", false) && machineConfiguration.isMultiAxisConfiguration()) {
    if (_optimizeType == undefined) {
      var saveRotation = getRotation();
      getWorkPlaneMachineABC(_section, true);
      forward = getRotation().forward;
      setRotation(saveRotation); // reset rotation
    } else {
      var abc = getWorkPlaneMachineABC(_section, false);
      var forceAdjustment = settings.workPlaneMethod.optimizeType == OPTIMIZE_TABLES || settings.workPlaneMethod.optimizeType == OPTIMIZE_BOTH;
      forward = machineConfiguration.getOptimizedDirection(_section.workPlane.forward, abc, false, forceAdjustment);
    }
  } else {
    forward = getRotation().forward;
  }
  return forward;
}

function getRetractParameters() {
  var _arguments = typeof arguments[0] === "object" ? arguments[0].axes : arguments;
  var singleLine = arguments[0].singleLine == undefined ? true : arguments[0].singleLine;
  var words = []; // store all retracted axes in an array
  var retractAxes = new Array(false, false, false);
  var method = getProperty("safePositionMethod", "G53");  // fallback matches our configured default -- "undefined" here previously crashed Simulate when the property wasn't populated yet
  if (method == "clearanceHeight") {
    if (!is3D()) {
      error(localize("Safe retract option 'Clearance Height' is only supported when all operations are along the setup Z-axis."));
    }
    return undefined;
  }
  validate(settings.retract, "Setting 'retract' is required but not defined.");
  validate(_arguments.length != 0, "No axis specified for getRetractParameters().");
  for (i in _arguments) {
    retractAxes[_arguments[i]] = true;
  }
  if ((retractAxes[0] || retractAxes[1]) && !state.retractedZ) { // retract Z first before moving to X/Y home
    error(localize("Retracting in X/Y is not possible without being retracted in Z."));
    return undefined;
  }
  // special conditions
  if (retractAxes[0] || retractAxes[1]) {
    method = getSetting("retract.methodXY", method);
  }
  if (retractAxes[2]) {
    method = getSetting("retract.methodZ", method);
  }
  // define home positions
  var useZeroValues = (settings.retract.useZeroValues && settings.retract.useZeroValues.indexOf(method) != -1);
  var _xHome = machineConfiguration.hasHomePositionX() && !useZeroValues ? machineConfiguration.getHomePositionX() : toPreciseUnit(0, MM);
  var _yHome = machineConfiguration.hasHomePositionY() && !useZeroValues ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
  var _zHome = machineConfiguration.getRetractPlane() != 0 && !useZeroValues ? machineConfiguration.getRetractPlane() : toPreciseUnit(0, MM);
  for (var i = 0; i < _arguments.length; ++i) {
    switch (_arguments[i]) {
    case X:
      if (!state.retractedX) {
        words.push("X" + xyzFormat.format(_xHome));
        xOutput.reset();
        state.retractedX = true;
      }
      break;
    case Y:
      if (!state.retractedY) {
        words.push("Y" + xyzFormat.format(_yHome));
        yOutput.reset();
        state.retractedY = true;
      }
      break;
    case Z:
      if (!state.retractedZ) {
        words.push("Z" + xyzFormat.format(_zHome));
        zOutput.reset();
        state.retractedZ = true;
      }
      break;
    default:
      error(localize("Unsupported axis specified for getRetractParameters()."));
      return undefined;
    }
  }
  return {
    method     : method,
    retractAxes: retractAxes,
    words      : words,
    positions  : {
      x: retractAxes[0] ? _xHome : undefined,
      y: retractAxes[1] ? _yHome : undefined,
      z: retractAxes[2] ? _zHome : undefined},
    singleLine: singleLine};
}


// Start of machine simulation connection move support
var debugSimulation = false; // enable to output debug information for connection move support in the NC program
var TCPON = "TCP ON";
var TCPOFF = "TCP OFF";
var TWPON = "TWP ON";
var TWPOFF = "TWP OFF";
var TOOLCHANGE = "TOOL CHANGE";
var RETRACTTOOLAXIS = "RETRACT TOOLAXIS";
var WORK = "WORK CS";
var MACHINE = "MACHINE CS";
var MIN = "MIN";
var MAX = "MAX";
var SHORTEST = "SHORTEST";
var PROGRAMMED = "PROGRAMMED";
var WARNING_NON_RANGE = [0, 1, 2];
var isTwpOn;
var isTcpOn;
/**
 * Helper function for connection moves in machine simulation.
 * @param {Object} parameters An object containing the desired options for machine simulation.
 * @note Available properties are:
 * @param {Number} x X axis position, alternatively use MIN or MAX to move to the axis limit
 * @param {Number} y Y axis position, alternatively use MIN or MAX to move to the axis limit
 * @param {Number} z Z axis position, alternatively use MIN or MAX to move to the axis limit
 * @param {Number} a A axis position (in radians)
 * @param {Number} b B axis position (in radians)
 * @param {Number} c C axis position (in radians)
 * @param {Number} feed desired feedrate, automatically set to high/current feedrate if not specified
 * @param {String} mode mode TCPON | TCPOFF | TWPON | TWPOFF | TOOLCHANGE | RETRACTTOOLAXIS
 * @param {String} coordinates WORK | MACHINE - if undefined, work coordinates will be used by default
 * @param {Number} eulerAngles the calculated Euler angles for the workplane
 * @param {String} rotaryMode SHORTEST | PROGRAMMED - if undefined, the default rotary mode will be used
 * @example
  machineSimulation({a:abc.x, b:abc.y, c:abc.z, coordinates:MACHINE});
  machineSimulation({x:toPreciseUnit(200, MM), y:toPreciseUnit(200, MM), coordinates:MACHINE, mode:TOOLCHANGE});
  machineSimulation({a:abc.x, b:abc.y, c:abc.z, coordinates:MACHINE, rotaryMode:SHORTEST});
*/
function machineSimulation(parameters) {
  if (revision < 50198 || skipBlocks || (getSimulationStreamPath() == "" && !debugSimulation)) {
    return; // return when post kernel revision is lower than 50198 or when skipBlocks is enabled
  }
  getAxisLimit = function(axis, limit) {
    validate(limit == MIN || limit == MAX, subst(localize("Invalid argument \"%1\" passed to the machineSimulation function."), limit));
    var range = axis.getRange();
    if (range.isNonRange()) {
      var axisLetters = ["X", "Y", "Z"];
      var warningMessage = subst(localize("An attempt was made to move the \"%1\" axis to its MIN/MAX limits during machine simulation, but its range is set to \"unlimited\"." + EOL +
        "A limited range must be set for the \"%1\" axis in the machine definition, or these motions will not be shown in machine simulation."), axisLetters[axis.getCoordinate()]);
      warningOnce(warningMessage, WARNING_NON_RANGE[axis.getCoordinate()]);
      return undefined;
    }
    return limit == MIN ? range.minimum : range.maximum;
  };
  var x = (isNaN(parameters.x) && parameters.x) ? getAxisLimit(machineConfiguration.getAxisX(), parameters.x) : parameters.x;
  var y = (isNaN(parameters.y) && parameters.y) ? getAxisLimit(machineConfiguration.getAxisY(), parameters.y) : parameters.y;
  var z = (isNaN(parameters.z) && parameters.z) ? getAxisLimit(machineConfiguration.getAxisZ(), parameters.z) : parameters.z;
  var rotaryAxesErrorMessage = localize("Invalid argument for rotary axes passed to the machineSimulation function. Only numerical values are supported.");
  var a = (isNaN(parameters.a) && parameters.a) ? error(rotaryAxesErrorMessage) : parameters.a;
  var b = (isNaN(parameters.b) && parameters.b) ? error(rotaryAxesErrorMessage) : parameters.b;
  var c = (isNaN(parameters.c) && parameters.c) ? error(rotaryAxesErrorMessage) : parameters.c;
  var coordinates = parameters.coordinates;
  var eulerAngles = parameters.eulerAngles;
  var rotaryMode = parameters.rotaryMode;
  var feed = parameters.feed;
  if (feed === undefined && typeof gMotionModal !== "undefined") {
    feed = gMotionModal.getCurrent() !== 0;
  }
  var mode = parameters.mode;
  var performToolChange = mode == TOOLCHANGE;
  if (mode !== undefined && ![TCPON, TCPOFF, TWPON, TWPOFF, TOOLCHANGE, RETRACTTOOLAXIS].includes(mode)) {
    error(subst("Mode '%1' is not supported.", mode));
  }
  if (rotaryMode !== undefined && ![SHORTEST, PROGRAMMED].includes(rotaryMode)) {
    error(subst(localize("Rotary mode '%1' is not supported."), rotaryMode));
  }

  // mode takes precedence over TCP/TWP states
  var enableTCP = isTcpOn;
  var enableTWP = isTwpOn;
  if (mode === TCPON || mode === TCPOFF) {
    enableTCP = mode === TCPON;
  } else if (mode === TWPON || mode === TWPOFF) {
    enableTWP = mode === TWPON;
  } else {
    enableTCP = typeof state !== "undefined" && state.tcpIsActive;
    enableTWP = typeof state !== "undefined" && state.twpIsActive;
  }
  var disableTCP = !enableTCP;
  var disableTWP = !enableTWP;
  if (disableTWP) {
    simulation.setTWPModeOff();
    isTwpOn = false;
  }
  if (disableTCP) {
    simulation.setTCPModeOff();
    isTcpOn = false;
  }
  if (enableTCP) {
    simulation.setTCPModeOn();
    isTcpOn = true;
  }
  if (enableTWP) {
    if (settings.workPlaneMethod.eulerConvention == undefined) {
      simulation.setTWPModeAlignToCurrentPose();
    } else if (eulerAngles) {
      simulation.setTWPModeByEulerAngles(settings.workPlaneMethod.eulerConvention, eulerAngles.x, eulerAngles.y, eulerAngles.z);
    }
    isTwpOn = true;
  }
  if (mode == RETRACTTOOLAXIS) {
    simulation.retractAlongToolAxisToLimit();
  }

  if (debugSimulation) {
    writeln("  DEBUG" + JSON.stringify(parameters));
    writeln("  DEBUG" + JSON.stringify({isTwpOn:isTwpOn, isTcpOn:isTcpOn, feed:feed}));
  }

  if (x !== undefined || y !== undefined || z !== undefined || a !== undefined || b !== undefined || c !== undefined) {
    if (x !== undefined) {simulation.setTargetX(x);}
    if (y !== undefined) {simulation.setTargetY(y);}
    if (z !== undefined) {simulation.setTargetZ(z);}
    if (a !== undefined) {simulation.setTargetA(a);}
    if (b !== undefined) {simulation.setTargetB(b);}
    if (c !== undefined) {simulation.setTargetC(c);}

    if (feed != undefined && feed) {
      simulation.setMotionToLinear();
      simulation.setFeedrate(typeof feed == "number" ? feed : feedOutput.getCurrent() == 0 ? highFeedrate : feedOutput.getCurrent());
    } else {
      simulation.setMotionToRapid();
    }

    var supportsRotaryMode = rotaryMode !== undefined && revision >= 50338;
    var saveRotaryDirection = supportsRotaryMode ? simulation.getRotaryDirection() : undefined;
    if (supportsRotaryMode) {
      if (rotaryMode === SHORTEST) {
        simulation.setRotaryToGoShortestDirection();
      } else if (rotaryMode === PROGRAMMED) {
        simulation.setRotaryToGoProgrammedDirection();
      }
    }

    if (coordinates != undefined && coordinates == MACHINE) {
      simulation.moveToTargetInMachineCoords();
    } else {
      simulation.moveToTargetInWorkCoords();
    }

    if (supportsRotaryMode) {
      if (saveRotaryDirection === ROTARY_DIRECTION_AS_PROGRAMMED) {
        simulation.setRotaryToGoProgrammedDirection();
      } else {
        simulation.setRotaryToGoShortestDirection();
      }
    }
  }
  if (performToolChange) {
    simulation.performToolChangeCycle();
    simulation.moveToTargetInMachineCoords();
  }
}
// <<<<< INCLUDED FROM include_files/commonFunctions.cpi

// ===========================================================================
// ATC TOOL CHANGE -- MACHINE SIMULATION
// ===========================================================================
// The NC file only ever says "Tn M6"; the rack moves live inside the ATC's
// own macro, so Fusion's machine simulation has nothing to follow and the
// tool simply teleports. That hides exactly the moves most likely to hit
// something: a long tool traversing the table, and the rack entry/exit.
//
// machineSimulation() writes to the SIMULATION STREAM, not to the program.
// So the real path can be replayed for collision checking without a single
// extra line appearing in the output. Outside simulation every call here
// returns immediately, so this costs nothing on a normal post.
//
// KEEP IN SYNC WITH THE atc_custom: BLOCK IN config.yaml. These are the same
// numbers; nothing reads them from the machine.
// ===========================================================================
var atcGeometry = {
  safeZ          : 0,        // move_to_safe_z() is G53 G0 Z0
  firstToolNumber: 2,        // first_tool_number -- slot 1 holds T2
  slots          : [         // slot1_mpos_mm .. slot6_mpos_mm
    {x:  -1.100, y: -487.0, z: -176.0},  // T2
    {x:-100.200, y: -489.0, z: -174.5},  // T3
    {x:-198.100, y: -489.0, z: -173.1},  // T4
    {x:-283.800, y: -489.0, z: -172.8},  // T5
    {x:-380.000, y: -489.0, z: -172.9},  // T6
    {x:-477.200, y: -489.0, z: -172.3}   // T7
  ],
  holderPulloff  : {x:0, y:35.0, z:15.0}, // tool_holder_pulloff_mm
  ets            : {x: -22.400, y: -22.000, z: -294.0}, // ets_mpos_mm
  etsRapidZOffset: 10.0      // ets_rapid_z_offset_mm
};

// What the spindle had in it last. -1 means unknown, which is the honest
// state at program start -- the ATC remembers across power cycles but Fusion
// cannot know, so the first change skips the drop and only shows the pick.
var atcSimulatedTool = -1;

function atcSlotIndex(toolNumber) {
  var i = toolNumber - atcGeometry.firstToolNumber;
  return (i >= 0 && i < atcGeometry.slots.length) ? i : -1;
}

// Drop the tool currently in the spindle back into its fork. Mirrors
// Every position in atcGeometry is a MACHINE coordinate -- they are the
// mpos values out of config.yaml, and the ATC drives to them with G53. So
// every one of these has to go in as coordinates:MACHINE. Two things go
// wrong without it:
//
//   1. machineSimulation() falls through to moveToTargetInWorkCoords(),
//      which the simulation API counts as a WCS ACTIVATION. Once one has
//      happened in a connection, performToolChangeCycle() is refused with
//      "A tool change was requested via the simulation API when a tool
//      change or WCS activation has already occurred earlier in the
//      connection" -- which is what the rack replay was doing to itself.
//   2. The rack would be drawn at the work offset instead of where it
//      physically is, so the collision check -- the entire point of the
//      replay -- would be checking the wrong piece of table.
//
// feed defaults to false as well. machineSimulation() otherwise infers it
// from gMotionModal, so a rack rapid would be simulated as a feed move
// whenever G1 happened to be modal when the tool change landed.
function atcSimMove(p) {
  p.coordinates = MACHINE;
  if (p.feed === undefined) {
    p.feed = false;
  }
  machineSimulation(p);
}

// Custom_ATC::drop_tool(): approach at the pull-off Y, descend to holder
// height, slide IN along Y, then lift off the taper.
function atcSimDrop(slot) {
  var s = atcGeometry.slots[slot];
  var p = atcGeometry.holderPulloff;
  atcSimMove({z:atcGeometry.safeZ});
  atcSimMove({x:s.x, y:s.y + p.y});
  atcSimMove({z:s.z});
  atcSimMove({y:s.y});          // into the fork
  atcSimMove({z:s.z + p.z});    // lift off the taper
  atcSimMove({z:atcGeometry.safeZ});
}

// Mirrors Custom_ATC::pick_tool(): position over the holder while it sits in
// the fork, descend onto the taper (a G1, hence feed), then slide OUT along
// Y before retracting.
function atcSimPick(slot) {
  var s = atcGeometry.slots[slot];
  var p = atcGeometry.holderPulloff;
  atcSimMove({z:atcGeometry.safeZ});
  atcSimMove({x:s.x, y:s.y});
  atcSimMove({z:s.z + p.z});
  atcSimMove({z:s.z, feed:1000});  // G53 G1 Z.. F1000 onto the taper
  atcSimMove({y:s.y + p.y});       // out of the fork
  atcSimMove({z:atcGeometry.safeZ});
}

// Mirrors move_over_toolsetter() plus stage 1 of probe_toolsetter(). The
// descent uses this tool's body length, the same quantity the post already
// hands the firmware as #<_fusion_tool_gauge>, so a long tool is shown
// descending less far -- which is the point of watching it.
// move_to_safe_z() + move_over_toolsetter(). This is where the operator takes
// a tool out or puts one in, and where anything that needs measuring gets
// measured. Ends at safe Z over the setter.
function atcSimParkOverToolsetter() {
  atcSimMove({z:atcGeometry.safeZ});
  atcSimMove({x:atcGeometry.ets.x, y:atcGeometry.ets.y});
}

// Stage 1 of probe_toolsetter(): descend by this tool's body length -- the
// same quantity the post hands the firmware as #<_fusion_tool_gauge> -- then
// back to safe Z. A long tool is shown descending less far, which is the
// point of watching it. Assumes the probe is already parked over the setter.
function atcSimProbeToolsetter(bodyLength) {
  atcSimMove({z:atcGeometry.ets.z + atcGeometry.etsRapidZOffset + bodyLength});
  atcSimMove({z:atcGeometry.safeZ});
}

// Replays the whole change: the drop, the pick and the toolsetter stage.
// This replay deliberately does NOT ask for mode:TOOLCHANGE anywhere.
//
// Fusion performs the tool change itself when it processes the toolpath, and
// performToolChangeCycle() is allowed once per connection -- so the post
// asking for a second one fails with "A tool change was requested via the
// simulation API when a tool change or WCS activation has already occurred
// earlier in the connection", wherever in the sequence it is put and whether
// the surrounding moves are in work or machine coordinates.
//
// The cost is only WHEN the model swaps: Fusion does it at its own moment
// rather than at the instant the drawbar closes, so part of the rack path
// may be drawn holding the wrong tool. The path itself -- which is what the
// replay exists to collision-check -- is unaffected.
function atcSimulateToolChange(newTool, bodyLength) {
  if (!SIMULATE_ATC_MOVES) {
    atcSimulatedTool = newTool; // no path drawn; Fusion swaps the tool as usual
    return;
  }
  var oldSlot = (atcSimulatedTool >= 0) ? atcSlotIndex(atcSimulatedTool) : -1;
  var newSlot = atcSlotIndex(newTool);

  // ---- put the old tool away ----
  if (oldSlot >= 0) {
    atcSimDrop(oldSlot);              // rack tool goes back to its own pocket
  } else if (atcSimulatedTool > 0) {
    atcSimParkOverToolsetter();       // anything else: the operator takes it out
  }
  // atcSimulatedTool < 0 means the spindle is assumed empty, so nothing to
  // put away. That is the honest state at program start: the firmware
  // remembers _prev_tool across power cycles, Fusion cannot.

  // ---- get the new tool ----
  if (newSlot >= 0) {
    // Rack tool. pick_tool() then apply_tlo_from_gauge() -- the pocket's
    // gauge length is already stored, so there is NO touch-off and the next
    // thing that happens is cutting. (The firmware does probe a pocket the
    // very first time it is used, but whether a gauge is stored is firmware
    // state the post cannot see, so the normal case is what gets drawn.)
    atcSimPick(newSlot);
  } else {
    atcSimParkOverToolsetter();       // the operator installs it here, on M0
    if (newTool != PROBE_TOOL) {
      // Everything outside the rack is touched off -- no gauge is stored for
      // them. T1 is the exception: the probe carries a fixed, manually
      // entered gauge length and is never touched off.
      atcSimProbeToolsetter(bodyLength);
    }
  }

  atcSimulatedTool = newTool;
}

// >>>>> INCLUDED FROM include_files/defineMachine.cpi
function defineMachine() {
  var useTCP = true;
  // Overriding the machine configuration is what makes Fusion say "Machine
  // configuration is overridden by the post script" and refuse to simulate
  // with the machine: the kinematics it would simulate against have been
  // replaced by ones it cannot see. So when a setup has a machine selected,
  // use it, and keep the built-in definition below as the fallback for a
  // setup with no machine. validateMachineDefinition() in onOpen then checks
  // the selected one actually describes this machine, because a definition
  // that is missing the B axis or has TCP off would quietly change what gets
  // posted rather than failing.
  usingFusionMachine = receivedMachineConfiguration &&
    MACHINE_CONFIG_SOURCE == "fusion";
  if (!usingFusionMachine) {
    // B rotary on the TABLE, axis along machine Y, carrying the part.
    //
    // table:true is not cosmetic. It tells Fusion the PART rotates rather
    // than the head, which decides which side of the cut gets compensated.
    //
    // tcp:true is what makes tcp.isSupportedByMachine true, which stops
    // Fusion baking the pivot geometry into the posted XYZ. That is the
    // whole point: the firmware does it instead, from a measured pivot and
    // a measured axis vector.
    //
    // axis:[0,1,0] stays NOMINAL on purpose. The real axis is tilted about
    // 0.11 deg and TCPCartesian compensates it from its own measurement.
    // Putting the measured tilt here as well would apply it twice. Fusion
    // only needs this for reach and limit checking.
    //
    // The rotary does not home, so its range is unlimited.
    var bAxis = createAxis({coordinate:1, table:true, axis:[0, 1, 0], cyclic:true, preference:0, tcp:useTCP});
    machineConfiguration = new MachineConfiguration(bAxis);

    setMachineConfiguration(machineConfiguration);
    if (receivedMachineConfiguration) {
      warning(localize("The provided CAM machine configuration is overwritten by the postprocessor."));
      receivedMachineConfiguration = false; // CAM provided machine configuration is overwritten
    }
  }

  if (!receivedMachineConfiguration) {
    // multiaxis settings
    if (machineConfiguration.isHeadConfiguration()) {
      machineConfiguration.setVirtualTooltip(false); // translate the pivot point to the virtual tool tip for nonTCP rotary heads
    }

    // Retract/reconfigure (rewind) is left to the machine definition: with a
    // machine selected, activateMachine reads performRewinds() from it, so a
    // local flag here would not have disabled anything either way.

    // multi-axis feedrates
    if (machineConfiguration.isMultiAxisConfiguration()) {
      machineConfiguration.setMultiAxisFeedrate(
        useTCP ? FEED_FPM : getProperty("useDPMFeeds") ? FEED_DPM : FEED_INVERSE_TIME,
        9999.99, // maximum output value for inverse time feed rates
        getProperty("useDPMFeeds") ? DPM_COMBINATION : INVERSE_MINUTES, // INVERSE_MINUTES/INVERSE_SECONDS or DPM_COMBINATION/DPM_STANDARD
        0.5, // tolerance to determine when the DPM feed has changed
        1.0 // ratio of rotary accuracy to linear accuracy for DPM calculations
      );
      setMachineConfiguration(machineConfiguration);
    }
  }
}
// <<<<< INCLUDED FROM include_files/defineMachine.cpi
// >>>>> INCLUDED FROM include_files/defineWorkPlane.cpi
validate(settings.workPlaneMethod, "Setting 'workPlaneMethod' is required but not defined.");
function defineWorkPlane(_section, _setWorkPlane) {
  var abc = new Vector(0, 0, 0);
  if (settings.workPlaneMethod.forceMultiAxisIndexing || !is3D() || machineConfiguration.isMultiAxisConfiguration()) {
    if (isPolarModeActive()) {
      abc = getCurrentDirection();
    } else if (_section.isMultiAxis()) {
      forceWorkPlane();
      cancelTransformation();
      abc = _section.isOptimizedForMachine() ? _section.getInitialToolAxisABC() : _section.getGlobalInitialToolAxis();
    } else if (settings.workPlaneMethod.useTiltedWorkplane && settings.workPlaneMethod.eulerConvention != undefined) {
      if (settings.workPlaneMethod.eulerCalculationMethod == "machine" && machineConfiguration.isMultiAxisConfiguration()) {
        abc = machineConfiguration.getOrientation(getWorkPlaneMachineABC(_section, true)).getEuler2(settings.workPlaneMethod.eulerConvention);
      } else {
        abc = _section.workPlane.getEuler2(settings.workPlaneMethod.eulerConvention);
      }
    } else {
      abc = getWorkPlaneMachineABC(_section, true);
    }

    if (_setWorkPlane) {
      if (_section.isMultiAxis() || isPolarModeActive()) { // 4-5x simultaneous operations
        if (_section.isOptimizedForMachine()) {
          positionABC(abc, true);
        } else {
          setCurrentDirection(abc);
        }
      } else { // 3x and/or 3+2x operations
        setWorkPlane(abc);
      }
    }
  } else {
    var remaining = _section.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return abc;
    }
    setRotation(remaining);
  }
  tcp.isSupportedByOperation = isTCPSupportedByOperation(_section);
  return abc;
}

function isTCPSupportedByOperation(_section) {
  var _tcp = _section.getOptimizedTCPMode() == OPTIMIZE_NONE;
  if (!_section.isMultiAxis() && (settings.workPlaneMethod.useTiltedWorkplane ||
    (machineConfiguration.isMultiAxisConfiguration() && settings.workPlaneMethod.optimizeType != undefined ?
      getWorkPlaneMachineABC(_section, false).isZero() : isSameDirection(machineConfiguration.getSpindleAxis(), getForwardDirection(_section))) ||
    settings.workPlaneMethod.optimizeType == OPTIMIZE_HEADS ||
    settings.workPlaneMethod.optimizeType == OPTIMIZE_TABLES ||
    settings.workPlaneMethod.optimizeType == OPTIMIZE_BOTH)) {
    _tcp = false;
  }
  return _tcp;
}
// <<<<< INCLUDED FROM include_files/defineWorkPlane.cpi
// >>>>> INCLUDED FROM include_files/getWorkPlaneMachineABC.cpi
validate(settings.machineAngles, "Setting 'machineAngles' is required but not defined.");
function getWorkPlaneMachineABC(_section, rotate) {
  var currentABC = isFirstSection() ? new Vector(0, 0, 0) : getCurrentABC();
  var abc = _section.getABCByPreference(machineConfiguration, _section.workPlane, currentABC, settings.machineAngles.controllingAxis, settings.machineAngles.type, settings.machineAngles.options);
  if (!isSameDirection(machineConfiguration.getDirection(abc), _section.workPlane.forward)) {
    error(localize("Orientation not supported."));
  }
  if (rotate) {
    if (settings.workPlaneMethod.optimizeType == undefined || settings.workPlaneMethod.useTiltedWorkplane) { // legacy
      var useTCP = false;
      var R = machineConfiguration.getRemainingOrientation(abc, _section.workPlane);
      setRotation(useTCP ? _section.workPlane : R);
    } else {
      if (!_section.isOptimizedForMachine()) {
        machineConfiguration.setToolLength(getSetting("workPlaneMethod.compensateToolLength", false) ? getBodyLength(_section.getTool()) : 0); // define the tool length for head adjustments
        _section.optimize3DPositionsByMachine(machineConfiguration, abc, settings.workPlaneMethod.optimizeType);
      }
    }
  }
  return abc;
}
// <<<<< INCLUDED FROM include_files/getWorkPlaneMachineABC.cpi
// >>>>> INCLUDED FROM include_files/positionABC.cpi
function positionABC(abc, force) {
  if (!machineConfiguration.isMultiAxisConfiguration()) {
    error("Function 'positionABC' can only be used with multi-axis machine configurations.");
  }
  if (typeof unwindABC == "function") {
    unwindABC(abc);
  }
  if (force) {
    forceABC();
  }
  var a = aOutput.format(abc.x);
  var b = bOutput.format(abc.y);
  var c = cOutput.format(abc.z);
  if (a || b || c) {
    writeRetract(Z);
    if (getSetting("retract.homeXY.onIndexing", false)) {
      writeRetract(settings.retract.homeXY.onIndexing);
    }
    onCommand(COMMAND_UNLOCK_MULTI_AXIS);
    gMotionModal.reset();
    writeBlock(gMotionModal.format(0), a, b, c);
    setCurrentABC(abc); // required for machine simulation
    machineSimulation({a:abc.x, b:abc.y, c:abc.z, coordinates:MACHINE});
  }
}
// <<<<< INCLUDED FROM include_files/positionABC.cpi
// >>>>> INCLUDED FROM include_files/coolant.cpi
var currentCoolantMode = COOLANT_OFF;
var coolantOff = undefined;
var isOptionalCoolant = false;
var forceCoolant = false;

function setCoolant(coolant) {
  var coolantCodes = getCoolantCodes(coolant);
  if (Array.isArray(coolantCodes)) {
    writeStartBlocks(!isOptionalCoolant, function () {
      if (settings.coolant.singleLineCoolant) {
        writeBlock(coolantCodes.join(getWordSeparator()));
      } else {
        for (var c in coolantCodes) {
          writeBlock(coolantCodes[c]);
        }
      }
    });
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant, format) {
  if (!getProperty("useCoolant", true)) {
    return undefined; // coolant output is disabled by property if it exists
  }
  isOptionalCoolant = false;
  if (typeof operationNeedsSafeStart == "undefined") {
    operationNeedsSafeStart = false;
  }
  var multipleCoolantBlocks = new Array(); // create a formatted array to be passed into the outputted line
  var coolants = settings.coolant.coolants;
  if (!coolants) {
    error(localize("Coolants have not been defined."));
  }
  if (tool.type && tool.type == TOOL_PROBE) { // avoid coolant output for probing
    coolant = COOLANT_OFF;
  }
  if (coolant == currentCoolantMode) {
    if (operationNeedsSafeStart && coolant != COOLANT_OFF) {
      isOptionalCoolant = true;
    } else if (!forceCoolant || coolant == COOLANT_OFF) {
      return undefined; // coolant is already active
    }
  }
  if ((coolant != COOLANT_OFF) && (currentCoolantMode != COOLANT_OFF) && (coolantOff != undefined) && !forceCoolant && !isOptionalCoolant) {
    if (Array.isArray(coolantOff)) {
      for (var i in coolantOff) {
        multipleCoolantBlocks.push(coolantOff[i]);
      }
    } else {
      multipleCoolantBlocks.push(coolantOff);
    }
  }
  forceCoolant = false;

  var m;
  var coolantCodes = {};
  for (var c in coolants) { // find required coolant codes into the coolants array
    if (coolants[c].id == coolant) {
      coolantCodes.on = coolants[c].on;
      if (coolants[c].off != undefined) {
        coolantCodes.off = coolants[c].off;
        break;
      } else {
        for (var i in coolants) {
          if (coolants[i].id == COOLANT_OFF) {
            coolantCodes.off = coolants[i].off;
            break;
          }
        }
      }
    }
  }
  if (coolant == COOLANT_OFF) {
    m = !coolantOff ? coolantCodes.off : coolantOff; // use the default coolant off command when an 'off' value is not specified
  } else {
    coolantOff = coolantCodes.off;
    m = coolantCodes.on;
  }

  if (!m) {
    onUnsupportedCoolant(coolant);
    m = 9;
  } else {
    if (Array.isArray(m)) {
      for (var i in m) {
        multipleCoolantBlocks.push(m[i]);
      }
    } else {
      multipleCoolantBlocks.push(m);
    }
    currentCoolantMode = coolant;
    for (var i in multipleCoolantBlocks) {
      if (typeof multipleCoolantBlocks[i] == "number") {
        multipleCoolantBlocks[i] = mFormat.format(multipleCoolantBlocks[i]);
      }
    }
    if (format == undefined || format) {
      return multipleCoolantBlocks; // return the single formatted coolant value
    } else {
      return m; // return unformatted coolant value
    }
  }
  return undefined;
}
// <<<<< INCLUDED FROM include_files/coolant.cpi
// >>>>> INCLUDED FROM include_files/writeWCS.cpi
function writeWCS(section, wcsIsRequired) {
  if (section.workOffset != currentWorkOffset) {
    if (typeof forceWorkPlane == "function" && wcsIsRequired) {
      forceWorkPlane();
    }
    writeStartBlocks(wcsIsRequired, function () {
      writeBlock(section.wcs);
    });
    currentWorkOffset = section.workOffset;
    if (revision >= 50338 && getCurrentSectionId() > 0 && section.workOffset != getPreviousSection().workOffset) {
      simulation.activateWorkCoordsForNextOperation();
    }
  }
}
// <<<<< INCLUDED FROM include_files/writeWCS.cpi
// >>>>> INCLUDED FROM include_files/writeToolCall.cpi
function writeToolCall(tool, insertToolCall) {
  if (!isFirstSection()) {
    writeStartBlocks(!getProperty("safeStartAllOperations") && insertToolCall, function () {
      writeRetract(Z); // write optional Z retract before tool change if safeStartAllOperations is enabled
    });
  }
  writeStartBlocks(insertToolCall, function () {
    writeRetract(Z);
    if (getSetting("retract.homeXY.onToolChange", false)) {
      writeRetract(settings.retract.homeXY.onToolChange);
    }
    if (!isFirstSection() && insertToolCall) {
      if (typeof forceWorkPlane == "function") {
        forceWorkPlane();
      }
      onCommand(COMMAND_COOLANT_OFF); // turn off coolant on tool change
    }

    if (tool.manualToolChange) {
      onCommand(COMMAND_STOP);
      writeComment("MANUAL TOOL CHANGE TO T" + toolFormat.format(mapTool(tool.number)));
    } else {
      if (!isFirstSection() && getProperty("optionalStop") && insertToolCall) {
        onCommand(COMMAND_OPTIONAL_STOP);
      }
      onCommand(COMMAND_LOAD_TOOL);
    }
  });
  if (typeof forceModals == "function" && (insertToolCall || getProperty("safeStartAllOperations"))) {
    forceModals();
  }
}
// <<<<< INCLUDED FROM include_files/writeToolCall.cpi
// >>>>> INCLUDED FROM include_files/startSpindle.cpi
function startSpindle(tool, insertToolCall) {
  if (tool.type != TOOL_PROBE) {
    var spindleSpeedIsRequired = insertToolCall || forceSpindleSpeed || isFirstSection() ||
      rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent()) ||
      (tool.clockwise != getPreviousSection().getTool().clockwise);

    writeStartBlocks(spindleSpeedIsRequired, function () {
      if (spindleSpeedIsRequired || operationNeedsSafeStart) {
        onCommand(COMMAND_START_SPINDLE);
      }
    });
  }
}
// <<<<< INCLUDED FROM include_files/startSpindle.cpi
// >>>>> INCLUDED FROM include_files/writeProgramHeader.cpi
function writeProgramHeader() {
  writeComment("posted " + postedAtText());

  writeln("");
  writeComment("OPERATIONS");
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var name = getSection(i).getParameter("operation-comment", "");
    writeComment("  " + (i + 1) + "  " + (name ? name : "unnamed"));
  }

  writeln("");
  writeComment("TOOLS");
  var tools = getToolTable();
  for (var i = 0; i < tools.getNumberOfTools(); ++i) {
    writeToolSummary(tools.getTool(i), "  ");
  }

  // Only when the numbers in this file differ from the ones in Fusion. The
  // operator is loading tools by hand here, so the mapping is the difference
  // between loading the right tool and the wrong one.
  if (noAtcMachine && toolRenumberList.length) {
    writeln("");
    writeComment("TOOL NUMBERS DIFFER FROM FUSION - no changer on this machine");
    for (var i = 0; i < toolRenumberList.length; ++i) {
      writeComment("  Fusion T" + toolRenumberList[i][0] +
        "  ->  load as T" + toolRenumberList[i][1]);
    }
  }
}

// Local time, to the minute. Which file is on the machine is a question that
// comes up at the machine, so the stamp is in the header rather than only in
// the file system.
function postedAtText() {
  var d = new Date();
  function pad(n) {
    return (n < 10 ? "0" : "") + n;
  }
  return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) +
    " " + pad(d.getHours()) + ":" + pad(d.getMinutes());
}

function toolName(tool) {
  return String(tool.description || tool.comment || getToolTypeName(tool.type));
}

function toolHolderName(tool) {
  return String(tool.holderDescription || tool.holderComment ||
    tool.holderProductId || "");
}

// How far the tool stands out past the nose of its holder. Fusion gives the
// assembly gauge length -- spindle gauge line to tool tip, which is what
// getBodyLength() returns and what the ATC is handed as
// #<_fusion_tool_gauge> -- and the holder's own length is measured from the
// same gauge line, so the difference is the part sticking out.
function toolStickout(tool) {
  var gauge = getBodyLength(tool);
  var holder = tool.holderLength;
  return (gauge > 0 && holder > 0 && gauge > holder) ? (gauge - holder) : undefined;
}

// One tool, two lines. Shared by the header and the manual-change comment so
// the operator reads the same description in both places.
function writeToolSummary(tool, indent) {
  var posted = mapTool(tool.number);
  writeComment(indent + "T" + toolFormat.format(posted) +
    (posted != tool.number ? " (Fusion T" + tool.number + ")" : "") +
    "  " + toolName(tool));
  var detail = "";
  var stickout = toolStickout(tool);
  if (stickout !== undefined) {
    detail = "stickout " + xyzFormat.format(stickout);
  }
  var holder = toolHolderName(tool);
  if (holder) {
    detail += (detail ? "  " : "") + "in " + holder;
  }
  if (detail) {
    writeComment(indent + "    " + detail);
  }
}
// <<<<< INCLUDED FROM include_files/writeProgramHeader.cpi

// >>>>> INCLUDED FROM include_files/workPlaneFunctions_fanuc.cpi
// No G68/G69 in FluidNC, so there is no work-plane rotation to cancel and
// gRotationModal, cancelWorkPlane() and cancelWCSRotation() are all gone with
// it. forceWorkPlane() stays: it is how an indexing move is forced to be
// re-emitted, which has nothing to do with rotation codes.
var currentWorkPlaneABC = undefined;
function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
  if (!settings.workPlaneMethod.forceMultiAxisIndexing && is3D() && !machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }
  var workplaneIsRequired = (currentWorkPlaneABC == undefined) ||
    abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
    abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
    abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z);

  writeStartBlocks(workplaneIsRequired, function () {
    writeRetract(Z);
    if (getSetting("retract.homeXY.onIndexing", false)) {
      writeRetract(settings.retract.homeXY.onIndexing);
    }
    if (typeof cancelLengthCompensation == "function") {
      cancelLengthCompensation(); // cancel tool lenght compensation / TCP prior to output TWP
    }
    // Tilted workplane (G68.2 + G53.1) is not an option here: FluidNC's
    // gcode parser has no G68 and no G69 at all, so the part is indexed by
    // rotating the axis and nothing else.
    positionABC(abc, true);
    if (!currentSection.isMultiAxis()) {
      onCommand(COMMAND_LOCK_MULTI_AXIS);
    }
    currentWorkPlaneABC = abc;
  });
}
// <<<<< INCLUDED FROM include_files/workPlaneFunctions_fanuc.cpi
// >>>>> INCLUDED FROM include_files/initialPositioning_fanuc.cpi
/**
 * Writes the initial positioning procedure for a section to get to the start position of the toolpath.
 * @param {Vector} position The initial position to move to
 * @param {boolean} isRequired true: Output full positioning, false: Output full positioning in optional state or output simple positioning only
 * @param {String} codes1 Allows to add additional code to the first positioning line
 * @param {String} codes2 Allows to add additional code to the second positioning line (if applicable)
 * @example
  var myVar1 = formatWords("T" + tool.number, currentSection.wcs);
  var myVar2 = getCoolantCodes(tool.coolant);
  writeInitialPositioning(initialPosition, isRequired, myVar1, myVar2);
*/
function writeInitialPositioning(position, isRequired, codes1, codes2) {
  var motionCode = {single:0, multi:0};
  switch (highFeedMapping) {
  case HIGH_FEED_MAP_ANY:
    motionCode = {single:1, multi:1}; // map all rapid traversals to high feed
    break;
  case HIGH_FEED_MAP_MULTI:
    motionCode = {single:0, multi:1}; // map rapid traversal along more than one axis to high feed
    break;
  }
  var feed = (highFeedMapping != HIGH_FEED_NO_MAPPING) ? getFeed(highFeedrate) : "";
  var additionalCodes = [formatWords(codes1), formatWords(codes2)];

  forceModals(gMotionModal);
  writeStartBlocks(isRequired, function() {
    var modalCodes = formatWords(gAbsIncModal.format(90), gPlaneModal.format(17));
    if (typeof cancelLengthCompensation == "function") {
      cancelLengthCompensation(!isRequired); // cancel tool length compensation prior to enabling it, required when switching G43/G43.4 modes
    }

    // One path only. The head-configuration branch is gone because this B
    // axis is on the table, and the tilted-workplane preposition branch is
    // gone because FluidNC has no G68.
    // Put the frame in place BEFORE positioning: with TCP on, the XYZ
    // below is the tool tip in the part frame, not a machine position.
    //
    // This is explicit because the kernel's usual mechanism cannot work
    // here. Normally TCP rides along with the length-compensation code --
    // G43.4 instead of G43 -- and lengthCompOutput's onchange handler sets
    // state.tcpIsActive from it. But this machine's ATC owns the tool
    // length and issues its own G43.1, so outputToolLengthCompensation is
    // false, which makes getLengthCompCode() disable lengthCompOutput and
    // return an empty string. Nothing is emitted, the handler never fires,
    // and M128 never went out at all: the post was relying on whatever
    // mode the controller happened to be left in.
    setTCP(tcp.isSupportedByOperation);
    writeBlock(modalCodes, gMotionModal.format(motionCode.multi), xOutput.format(position.x), yOutput.format(position.y), feed, additionalCodes[0]);
    machineSimulation({x:position.x, y:position.y});
    writeBlock(gMotionModal.format(motionCode.single), getLengthCompCode(), zOutput.format(position.z), additionalCodes[1]);
    machineSimulation(tcp.isSupportedByOperation ? {x:position.x, y:position.y, z:position.z} : {z:position.z});

    forceModals(gMotionModal);
    if (isRequired) {
      additionalCodes = []; // clear additionalCodes buffer
    }
  });

  validate(!validateLengthCompensation || state.lengthCompensationActive, "Tool length compensation is not active."); // make sure that lenght compensation is enabled
  if (!isRequired) { // simple positioning
    var modalCodes = formatWords(gAbsIncModal.format(90), gPlaneModal.format(17));
    forceXYZ();
    if (!state.retractedZ && xyzFormat.getResultingValue(getCurrentPosition().z) < xyzFormat.getResultingValue(position.z)) {
      writeBlock(modalCodes, gMotionModal.format(motionCode.single), zOutput.format(position.z), feed);
      machineSimulation({z:position.z});
    }
    writeBlock(modalCodes, gMotionModal.format(motionCode.multi), xOutput.format(position.x), yOutput.format(position.y), feed, additionalCodes);
    machineSimulation({x:position.x, y:position.y});
  }
  if (machineConfiguration.isMultiAxisConfiguration() && !currentSection.isMultiAxis()) {
    onCommand(COMMAND_LOCK_MULTI_AXIS);
  }
}

// <<<<< INCLUDED FROM include_files/initialPositioning_fanuc.cpi
// >>>>> INCLUDED FROM include_files/onRapid_fanuc.cpi
function onRapid(_x, _y, _z) {
  updateAdaptiveFeedForMovement();
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    writeBlock(gMotionModal.format(0), x, y, z);
    forceFeed();
  }
}
// <<<<< INCLUDED FROM include_files/onRapid_fanuc.cpi
// >>>>> INCLUDED FROM include_files/onLinear_fanuc.cpi
function onLinear(_x, _y, _z, feed) {
  updateAdaptiveFeedForMovement();
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = getFeed(feed);
  if (x || y || z) {
    writeBlock(gMotionModal.format(1), x, y, z, f);
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gMotionModal.format(1), f);
    }
  }
}
// <<<<< INCLUDED FROM include_files/onLinear_fanuc.cpi
// >>>>> INCLUDED FROM include_files/onRapid5D_fanuc.cpi
function onRapid5D(_x, _y, _z, _a, _b, _c) {
  updateAdaptiveFeedForMovement();
  // Tool vector output (I/J/K instead of ABC) is for controls that accept a
  // tool vector; FluidNC does not, and a non-optimised multi-axis section is
  // refused outright in activateMachine.
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);

  if (x || y || z || a || b || c) {
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
    forceFeed();
  }
}
// <<<<< INCLUDED FROM include_files/onRapid5D_fanuc.cpi
// >>>>> INCLUDED FROM include_files/onLinear5D_fanuc.cpi
function onLinear5D(_x, _y, _z, _a, _b, _c, feed, feedMode) {
  updateAdaptiveFeedForMovement();
  // Tool vector output (I/J/K instead of ABC) is for controls that accept a
  // tool vector; FluidNC does not, and a non-optimised multi-axis section is
  // refused outright in activateMachine.
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  if (feedMode == FEED_INVERSE_TIME) {
    forceFeed();
  }
  var f = feedMode == FEED_INVERSE_TIME ? inverseTimeOutput.format(feed) : getFeed(feed);
  var fMode = feedMode == FEED_INVERSE_TIME ? 93 : 94;

  if (x || y || z || a || b || c) {
    writeBlock(gFeedModeModal.format(fMode), gMotionModal.format(1), x, y, z, a, b, c, f);
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      forceFeed(); // force feed on next line
    } else {
      writeBlock(gFeedModeModal.format(fMode), gMotionModal.format(1), f);
    }
  }
}
// <<<<< INCLUDED FROM include_files/onLinear5D_fanuc.cpi
// >>>>> INCLUDED FROM include_files/writeRetract_fanuc.cpi
function writeRetract() {
  var retract = getRetractParameters.apply(this, arguments);
  if (retract && retract.words.length > 0) {
    if (typeof setTCP == "function" && getSetting("allowCancelTCPBeforeRetracting", false)) {
      setTCP(false); // cancel TCP before retracting
    }
    for (var i in retract.words) {
      var words = retract.singleLine ? retract.words : retract.words[i];
      switch (retract.method) {
      case "G28":
        forceModals(gMotionModal, gAbsIncModal);
        writeBlock(gFormat.format(28), gAbsIncModal.format(91), words);
        writeBlock(gAbsIncModal.format(90));
        break;
      case "G30":
        forceModals(gMotionModal, gAbsIncModal);
        writeBlock(gFormat.format(30), gAbsIncModal.format(91), words);
        writeBlock(gAbsIncModal.format(90));
        break;
      case "G53":
        forceModals(gMotionModal);
        writeBlock(gAbsIncModal.format(90), gFormat.format(53), gMotionModal.format(0), words);
        break;
      default:
        if (typeof writeRetractCustom == "function") {
          writeRetractCustom(retract);
          return;
        } else {
          error(subst(localize("Unsupported safe position method '%1'"), retract.method));
        }
      }
      machineSimulation({
        x          : retract.singleLine || words.indexOf("X") != -1 ? retract.positions.x : undefined,
        y          : retract.singleLine || words.indexOf("Y") != -1 ? retract.positions.y : undefined,
        z          : retract.singleLine || words.indexOf("Z") != -1 ? retract.positions.z : undefined,
        coordinates: MACHINE
      });
      if (retract.singleLine) {
        break;
      }
    }
  }
}
// <<<<< INCLUDED FROM include_files/writeRetract_fanuc.cpi
// >>>>> INCLUDED FROM include_files/lengthCompFunctions_fanuc.cpi
if (typeof lengthCompCodes === "undefined") {
  var lengthCompCodes = {tool:43, tcp:43.4, tcpVector:43.5, cancel:49};
}
var lengthCompOutput = createOutputVariable({control : CONTROL_FORCE,
  onchange: function() {
    state.tcpIsActive = lengthCompOutput.getCurrent() == lengthCompCodes.tcp || lengthCompOutput.getCurrent() == lengthCompCodes.tcpVector;
    state.lengthCompensationActive = lengthCompOutput.getCurrent() != lengthCompCodes.cancel;
    machineSimulation({}); // update machine simulation TCP state
  }
}, gFormat);

function getLengthCompCode(forceTCP) {
  if (!getSetting("outputToolLengthCompensation", true) && lengthCompOutput.isEnabled()) {
    state.lengthCompensationActive = true; // always assume that length compensation is active
    lengthCompOutput.disable();
  }
  var lengthCompCode = lengthCompCodes.tool;
  if (tcp.isSupportedByOperation || forceTCP) {
    lengthCompCode = machineConfiguration.isMultiAxisConfiguration() ? lengthCompCodes.tcp : lengthCompCodes.tcpVector;
  }
  return lengthCompOutput.format(lengthCompCode);
}

function setTCP(_tcp, force) {
  if (!force && state.tcpIsActive === _tcp) {
    return;
  }
  // FluidNC has no G43.4 / G43.5. TCP is a modal M-code pair handled by
  // TCPCartesian, so this writes M128 / M129 instead of a length-comp code.
  //
  // Tool length is NOT touched here either. The ATC owns it: the M6 macro
  // probes the toolsetter and issues its own G43.1. That is also why
  // outputToolLengthCompensation is false, which leaves lengthCompOutput
  // disabled and emitting nothing -- so cancelLengthCompensation() is not
  // called, and G49 never goes out to undo the ATC's work.
  writeBlock(mFormat.format(_tcp ? 128 : 129));
  state.tcpIsActive              = _tcp;
  state.lengthCompensationActive = true; // the ATC always leaves a TLO applied
  machineSimulation({mode:_tcp ? TCPON : TCPOFF});
  if (_tcp) {
    forceXYZ(); // the frame just changed; nothing modal survives it
  }
}
// <<<<< INCLUDED FROM include_files/lengthCompFunctions_fanuc.cpi
// >>>>> INCLUDED FROM include_files/rewind.cpi
function onMoveToSafeRetractPosition() {
  if (!getSetting("allowCancelTCPBeforeRetracting", false)) {
    writeRetract(Z);
  }
  if (state.tcpIsActive) { // cancel TCP so that tool doesn't follow rotaries
    setTCP(false);
  }
  writeRetract(Z);
  if (getSetting("retract.homeXY.onIndexing", false)) {
    writeRetract(settings.retract.homeXY.onIndexing);
  }
}

/** Rotate axes to new position above reentry position */
function onRotateAxes(_x, _y, _z, _a, _b, _c) {
  // position rotary axes
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  if (typeof unwindABC == "function") {
    unwindABC(new Vector(_a, _b, _c), false);
  }
  onRapid5D(_x, _y, _z, _a, _b, _c);
  setCurrentABC(new Vector(_a, _b, _c));
  machineSimulation({a:_a, b:_b, c:_c, coordinates:MACHINE});
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();
  forceXYZ();
}

/** Return from safe position after indexing rotaries. */
function onReturnFromSafeRetractPosition(_x, _y, _z) {
  if (!machineConfiguration.isHeadConfiguration()) {
    writeInitialPositioning(new Vector(_x, _y, _z), true);
    if (highFeedMapping != HIGH_FEED_NO_MAPPING) {
      onLinear5D(_x, _y, _z, getCurrentDirection().x, getCurrentDirection().y, getCurrentDirection().z, highFeedrate);
    } else {
      onRapid5D(_x, _y, _z, getCurrentDirection().x, getCurrentDirection().y, getCurrentDirection().z);
    }
    machineSimulation({x:_x, y:_y, z:_z, a:getCurrentDirection().x, b:getCurrentDirection().y, c:getCurrentDirection().z});
  } else {
    if (tcp.isSupportedByOperation) {
      setTCP(true);
    }
    forceXYZ();
    xOutput.reset();
    yOutput.reset();
    zOutput.disable();
    if (highFeedMapping != HIGH_FEED_NO_MAPPING) {
      onLinear(_x, _y, _z, highFeedrate);
    } else {
      onRapid(_x, _y, _z);
    }
    machineSimulation({x:_x, y:_y});
    zOutput.enable();
    invokeOnRapid(_x, _y, _z);
  }
}
// <<<<< INCLUDED FROM include_files/rewind.cpi
// <<<<< INCLUDED FROM ../common/grbl.cps
