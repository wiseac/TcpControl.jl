# Automatically generated using Clang.jl


const IVIFGEN_MAJOR_VERSION = Int32(5)
const IVIFGEN_MINOR_VERSION = Int32(0)
const IVIFGEN_CLASS_SPEC_MAJOR_VERSION = Int32(5)
const IVIFGEN_CLASS_SPEC_MINOR_VERSION = Int32(0)
const IVIFGEN_DRIVER_VENDOR = "National Instruments"
const IVIFGEN_DRIVER_DESCRIPTION = "IviFgen Class Driver"
const IVIFGEN_ATTR_CACHE = IVI_ATTR_CACHE
const IVIFGEN_ATTR_RANGE_CHECK = IVI_ATTR_RANGE_CHECK
const IVIFGEN_ATTR_QUERY_INSTRUMENT_STATUS = IVI_ATTR_QUERY_INSTRUMENT_STATUS
const IVIFGEN_ATTR_RECORD_COERCIONS = IVI_ATTR_RECORD_COERCIONS
const IVIFGEN_ATTR_SIMULATE = IVI_ATTR_SIMULATE
const IVIFGEN_ATTR_INTERCHANGE_CHECK = IVI_ATTR_INTERCHANGE_CHECK
const IVIFGEN_ATTR_SPY = IVI_ATTR_SPY
const IVIFGEN_ATTR_USE_SPECIFIC_SIMULATION = IVI_ATTR_USE_SPECIFIC_SIMULATION
const IVIFGEN_ATTR_GROUP_CAPABILITIES = IVI_ATTR_GROUP_CAPABILITIES
const IVIFGEN_ATTR_FUNCTION_CAPABILITIES = IVI_ATTR_FUNCTION_CAPABILITIES
const IVIFGEN_ATTR_CLASS_DRIVER_PREFIX = IVI_ATTR_CLASS_DRIVER_PREFIX
const IVIFGEN_ATTR_CLASS_DRIVER_VENDOR = IVI_ATTR_CLASS_DRIVER_VENDOR
const IVIFGEN_ATTR_CLASS_DRIVER_DESCRIPTION = IVI_ATTR_CLASS_DRIVER_DESCRIPTION
const IVIFGEN_ATTR_CLASS_DRIVER_CLASS_SPEC_MAJOR_VERSION = IVI_ATTR_CLASS_DRIVER_CLASS_SPEC_MAJOR_VERSION
const IVIFGEN_ATTR_CLASS_DRIVER_CLASS_SPEC_MINOR_VERSION = IVI_ATTR_CLASS_DRIVER_CLASS_SPEC_MINOR_VERSION
const IVIFGEN_ATTR_SPECIFIC_DRIVER_PREFIX = IVI_ATTR_SPECIFIC_DRIVER_PREFIX
const IVIFGEN_ATTR_SPECIFIC_DRIVER_LOCATOR = IVI_ATTR_SPECIFIC_DRIVER_LOCATOR
const IVIFGEN_ATTR_IO_RESOURCE_DESCRIPTOR = IVI_ATTR_IO_RESOURCE_DESCRIPTOR
const IVIFGEN_ATTR_LOGICAL_NAME = IVI_ATTR_LOGICAL_NAME
const IVIFGEN_ATTR_SPECIFIC_DRIVER_VENDOR = IVI_ATTR_SPECIFIC_DRIVER_VENDOR
const IVIFGEN_ATTR_SPECIFIC_DRIVER_DESCRIPTION = IVI_ATTR_SPECIFIC_DRIVER_DESCRIPTION
const IVIFGEN_ATTR_SPECIFIC_DRIVER_CLASS_SPEC_MAJOR_VERSION = IVI_ATTR_SPECIFIC_DRIVER_CLASS_SPEC_MAJOR_VERSION
const IVIFGEN_ATTR_SPECIFIC_DRIVER_CLASS_SPEC_MINOR_VERSION = IVI_ATTR_SPECIFIC_DRIVER_CLASS_SPEC_MINOR_VERSION
const IVIFGEN_ATTR_INSTRUMENT_FIRMWARE_REVISION = IVI_ATTR_INSTRUMENT_FIRMWARE_REVISION
const IVIFGEN_ATTR_INSTRUMENT_MANUFACTURER = IVI_ATTR_INSTRUMENT_MANUFACTURER
const IVIFGEN_ATTR_INSTRUMENT_MODEL = IVI_ATTR_INSTRUMENT_MODEL
const IVIFGEN_ATTR_SUPPORTED_INSTRUMENT_MODELS = IVI_ATTR_SUPPORTED_INSTRUMENT_MODELS
const IVIFGEN_ATTR_CLASS_DRIVER_REVISION = IVI_ATTR_CLASS_DRIVER_REVISION
const IVIFGEN_ATTR_SPECIFIC_DRIVER_REVISION = IVI_ATTR_SPECIFIC_DRIVER_REVISION
const IVIFGEN_ATTR_DRIVER_SETUP = IVI_ATTR_DRIVER_SETUP
const IVIFGEN_ATTR_CHANNEL_COUNT = IVI_ATTR_CHANNEL_COUNT
const IVIFGEN_ATTR_OUTPUT_MODE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(1)
const IVIFGEN_ATTR_REF_CLOCK_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(2)
const IVIFGEN_ATTR_OUTPUT_ENABLED = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(3)
const IVIFGEN_ATTR_OUTPUT_IMPEDANCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(4)
const IVIFGEN_ATTR_OPERATION_MODE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(5)
const IVIFGEN_ATTR_SAMPLE_CLOCK_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(21)
const IVIFGEN_ATTR_SAMPLE_CLOCK_OUTPUT_ENABLED = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(22)
const IVIFGEN_ATTR_TERMINAL_CONFIGURATION = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(31)
const IVIFGEN_ATTR_FUNC_WAVEFORM = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(101)
const IVIFGEN_ATTR_FUNC_AMPLITUDE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(102)
const IVIFGEN_ATTR_FUNC_DC_OFFSET = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(103)
const IVIFGEN_ATTR_FUNC_FREQUENCY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(104)
const IVIFGEN_ATTR_FUNC_START_PHASE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(105)
const IVIFGEN_ATTR_FUNC_DUTY_CYCLE_HIGH = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(106)
const IVIFGEN_ATTR_ARB_WAVEFORM_HANDLE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(201)
const IVIFGEN_ATTR_ARB_GAIN = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(202)
const IVIFGEN_ATTR_ARB_OFFSET = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(203)
const IVIFGEN_ATTR_ARB_SAMPLE_RATE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(204)
const IVIFGEN_ATTR_MAX_NUM_WAVEFORMS = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(205)
const IVIFGEN_ATTR_WAVEFORM_QUANTUM = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(206)
const IVIFGEN_ATTR_MIN_WAVEFORM_SIZE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(207)
const IVIFGEN_ATTR_MAX_WAVEFORM_SIZE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(208)
const IVIFGEN_ATTR_ARB_FREQUENCY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(209)
const IVIFGEN_ATTR_ARB_SEQUENCE_HANDLE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(211)
const IVIFGEN_ATTR_MAX_NUM_SEQUENCES = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(212)
const IVIFGEN_ATTR_MIN_SEQUENCE_LENGTH = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(213)
const IVIFGEN_ATTR_MAX_SEQUENCE_LENGTH = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(214)
const IVIFGEN_ATTR_MAX_LOOP_COUNT = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(215)
const IVIFGEN_ATTR_MIN_WAVEFORM_SIZE64 = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(221)
const IVIFGEN_ATTR_MAX_WAVEFORM_SIZE64 = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(222)
const IVIFGEN_ATTR_BINARY_ALIGNMENT = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(241)
const IVIFGEN_ATTR_SAMPLE_BIT_RESOLUTION = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(242)
const IVIFGEN_ATTR_OUTPUT_DATA_MASK = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(261)
const IVIFGEN_ATTR_SEQUENCE_DEPTH_MAX = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(281)
const IVIFGEN_ATTR_TRIGGER_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(302)
const IVIFGEN_ATTR_INTERNAL_TRIGGER_RATE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(310)
const IVIFGEN_ATTR_START_TRIGGER_DELAY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(320)
const IVIFGEN_ATTR_START_TRIGGER_SLOPE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(321)
const IVIFGEN_ATTR_START_TRIGGER_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(322)
const IVIFGEN_ATTR_START_TRIGGER_THRESHOLD = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(323)
const IVIFGEN_ATTR_STOP_TRIGGER_DELAY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(330)
const IVIFGEN_ATTR_STOP_TRIGGER_SLOPE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(331)
const IVIFGEN_ATTR_STOP_TRIGGER_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(332)
const IVIFGEN_ATTR_STOP_TRIGGER_THRESHOLD = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(333)
const IVIFGEN_ATTR_HOLD_TRIGGER_DELAY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(340)
const IVIFGEN_ATTR_HOLD_TRIGGER_SLOPE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(341)
const IVIFGEN_ATTR_HOLD_TRIGGER_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(342)
const IVIFGEN_ATTR_HOLD_TRIGGER_THRESHOLD = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(343)
const IVIFGEN_ATTR_BURST_COUNT = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(350)
const IVIFGEN_ATTR_RESUME_TRIGGER_DELAY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(360)
const IVIFGEN_ATTR_RESUME_TRIGGER_SLOPE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(361)
const IVIFGEN_ATTR_RESUME_TRIGGER_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(362)
const IVIFGEN_ATTR_RESUME_TRIGGER_THRESHOLD = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(363)
const IVIFGEN_ATTR_ADVANCE_TRIGGER_DELAY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(370)
const IVIFGEN_ATTR_ADVANCE_TRIGGER_SLOPE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(371)
const IVIFGEN_ATTR_ADVANCE_TRIGGER_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(372)
const IVIFGEN_ATTR_ADVANCE_TRIGGER_THRESHOLD = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(373)
const IVIFGEN_ATTR_AM_ENABLED = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(401)
const IVIFGEN_ATTR_AM_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(402)
const IVIFGEN_ATTR_AM_INTERNAL_DEPTH = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(403)
const IVIFGEN_ATTR_AM_INTERNAL_WAVEFORM = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(404)
const IVIFGEN_ATTR_AM_INTERNAL_FREQUENCY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(405)
const IVIFGEN_ATTR_FM_ENABLED = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(501)
const IVIFGEN_ATTR_FM_SOURCE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(502)
const IVIFGEN_ATTR_FM_INTERNAL_DEVIATION = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(503)
const IVIFGEN_ATTR_FM_INTERNAL_WAVEFORM = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(504)
const IVIFGEN_ATTR_FM_INTERNAL_FREQUENCY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(505)
const IVIFGEN_ATTR_DATAMARKER_AMPLITUDE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(601)
const IVIFGEN_ATTR_DATAMARKER_BIT_POSITION = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(602)
const IVIFGEN_ATTR_DATAMARKER_COUNT = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(603)
const IVIFGEN_ATTR_DATAMARKER_DELAY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(604)
const IVIFGEN_ATTR_DATAMARKER_DESTINATION = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(605)
const IVIFGEN_ATTR_DATAMARKER_POLARITY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(606)
const IVIFGEN_ATTR_DATAMARKER_SOURCE_CHANNEL = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(607)
const IVIFGEN_ATTR_SPARSEMARKER_AMPLITUDE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(701)
const IVIFGEN_ATTR_SPARSEMARKER_COUNT = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(702)
const IVIFGEN_ATTR_SPARSEMARKER_DELAY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(703)
const IVIFGEN_ATTR_SPARSEMARKER_DESTINATION = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(704)
const IVIFGEN_ATTR_SPARSEMARKER_POLARITY = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(705)
const IVIFGEN_ATTR_SPARSEMARKER_WFMHANDLE = IVI_CLASS_PUBLIC_ATTR_BASE + Int32(706)
const IVIFGEN_VAL_OUTPUT_FUNC = Int32(0)
const IVIFGEN_VAL_OUTPUT_ARB = Int32(1)
const IVIFGEN_VAL_OUTPUT_SEQ = Int32(2)
const IVIFGEN_VAL_OUT_MODE_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_OUT_MODE_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_OPERATE_CONTINUOUS = Int32(0)
const IVIFGEN_VAL_OPERATE_BURST = Int32(1)
const IVIFGEN_VAL_OP_MODE_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_OP_MODE_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_REF_CLOCK_INTERNAL = Int32(0)
const IVIFGEN_VAL_REF_CLOCK_EXTERNAL = Int32(1)
const IVIFGEN_VAL_REF_CLOCK_RTSI_CLOCK = Int32(101)
const IVIFGEN_VAL_CLK_SRC_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_CLK_SRC_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_WFM_SINE = Int32(1)
const IVIFGEN_VAL_WFM_SQUARE = Int32(2)
const IVIFGEN_VAL_WFM_TRIANGLE = Int32(3)
const IVIFGEN_VAL_WFM_RAMP_UP = Int32(4)
const IVIFGEN_VAL_WFM_RAMP_DOWN = Int32(5)
const IVIFGEN_VAL_WFM_DC = Int32(6)
const IVIFGEN_VAL_WFM_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_WFM_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_EXTERNAL = Int32(1)
const IVIFGEN_VAL_SOFTWARE_TRIG = Int32(2)
const IVIFGEN_VAL_INTERNAL_TRIGGER = Int32(3)
const IVIFGEN_VAL_TTL0 = Int32(111)
const IVIFGEN_VAL_TTL1 = Int32(112)
const IVIFGEN_VAL_TTL2 = Int32(113)
const IVIFGEN_VAL_TTL3 = Int32(114)
const IVIFGEN_VAL_TTL4 = Int32(115)
const IVIFGEN_VAL_TTL5 = Int32(116)
const IVIFGEN_VAL_TTL6 = Int32(117)
const IVIFGEN_VAL_TTL7 = Int32(118)
const IVIFGEN_VAL_ECL0 = Int32(119)
const IVIFGEN_VAL_ECL1 = Int32(120)
const IVIFGEN_VAL_PXI_STAR = Int32(131)
const IVIFGEN_VAL_RTSI_0 = Int32(141)
const IVIFGEN_VAL_RTSI_1 = Int32(142)
const IVIFGEN_VAL_RTSI_2 = Int32(143)
const IVIFGEN_VAL_RTSI_3 = Int32(144)
const IVIFGEN_VAL_RTSI_4 = Int32(145)
const IVIFGEN_VAL_RTSI_5 = Int32(146)
const IVIFGEN_VAL_RTSI_6 = Int32(147)
const IVIFGEN_VAL_TRIG_SRC_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_TRIG_SRC_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_TRIGGER_SOURCE_NONE = ""
const IVIFGEN_VAL_TRIGGER_SOURCE_IMMEDIATE = "Immediate"
const IVIFGEN_VAL_TRIGGER_SOURCE_EXTERNAL = "External"
const IVIFGEN_VAL_TRIGGER_SOURCE_INTERNAL = "Internal"
const IVIFGEN_VAL_TRIGGER_SOURCE_SOFTWARE = "Software"
const IVIFGEN_VAL_TRIGGER_SOURCE_LAN0 = "LAN0"
const IVIFGEN_VAL_TRIGGER_SOURCE_LAN1 = "LAN1"
const IVIFGEN_VAL_TRIGGER_SOURCE_LAN2 = "LAN2"
const IVIFGEN_VAL_TRIGGER_SOURCE_LAN3 = "LAN3"
const IVIFGEN_VAL_TRIGGER_SOURCE_LAN4 = "LAN4"
const IVIFGEN_VAL_TRIGGER_SOURCE_LAN5 = "LAN5"
const IVIFGEN_VAL_TRIGGER_SOURCE_LAN6 = "LAN6"
const IVIFGEN_VAL_TRIGGER_SOURCE_LAN7 = "LAN7"
const IVIFGEN_VAL_TRIGGER_SOURCE_LXI0 = "LXI0"
const IVIFGEN_VAL_TRIGGER_SOURCE_LXI1 = "LXI1"
const IVIFGEN_VAL_TRIGGER_SOURCE_LXI2 = "LXI2"
const IVIFGEN_VAL_TRIGGER_SOURCE_LXI3 = "LXI3"
const IVIFGEN_VAL_TRIGGER_SOURCE_LXI4 = "LXI4"
const IVIFGEN_VAL_TRIGGER_SOURCE_LXI5 = "LXI5"
const IVIFGEN_VAL_TRIGGER_SOURCE_LXI6 = "LXI6"
const IVIFGEN_VAL_TRIGGER_SOURCE_LXI7 = "LXI7"
const IVIFGEN_VAL_TRIGGER_SOURCE_TTL0 = "TTL0"
const IVIFGEN_VAL_TRIGGER_SOURCE_TTL1 = "TTL1"
const IVIFGEN_VAL_TRIGGER_SOURCE_TTL2 = "TTL2"
const IVIFGEN_VAL_TRIGGER_SOURCE_TTL3 = "TTL3"
const IVIFGEN_VAL_TRIGGER_SOURCE_TTL4 = "TTL4"
const IVIFGEN_VAL_TRIGGER_SOURCE_TTL5 = "TTL5"
const IVIFGEN_VAL_TRIGGER_SOURCE_TTL6 = "TTL6"
const IVIFGEN_VAL_TRIGGER_SOURCE_TTL7 = "TTL7"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_STAR = "PXI_STAR"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_TRIG0 = "PXI_TRIG0"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_TRIG1 = "PXI_TRIG1"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_TRIG2 = "PXI_TRIG2"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_TRIG3 = "PXI_TRIG3"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_TRIG4 = "PXI_TRIG4"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_TRIG5 = "PXI_TRIG5"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_TRIG6 = "PXI_TRIG6"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXI_TRIG7 = "PXI_TRIG7"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXIE_DSTARA = "PXIe_DSTARA"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXIE_DSTARB = "PXIe_DSTARB"
const IVIFGEN_VAL_TRIGGER_SOURCE_PXIE_DSTARC = "PXIe_DSTARC"
const IVIFGEN_VAL_TRIGGER_SOURCE_RTSI0 = "RTSI0"
const IVIFGEN_VAL_TRIGGER_SOURCE_RTSI1 = "RTSI1"
const IVIFGEN_VAL_TRIGGER_SOURCE_RTSI2 = "RTSI2"
const IVIFGEN_VAL_TRIGGER_SOURCE_RTSI3 = "RTSI3"
const IVIFGEN_VAL_TRIGGER_SOURCE_RTSI4 = "RTSI4"
const IVIFGEN_VAL_TRIGGER_SOURCE_RTSI5 = "RTSI5"
const IVIFGEN_VAL_TRIGGER_SOURCE_RTSI6 = "RTSI6"
const IVIFGEN_VAL_SAMPLE_CLOCK_SOURCE_INTERNAL = Int32(0)
const IVIFGEN_VAL_SAMPLE_CLOCK_SOURCE_EXTERNAL = Int32(1)
const IVIFGEN_VAL_MARKER_POLARITY_ACTIVE_HIGH = Int32(0)
const IVIFGEN_VAL_MARKER_POLARITY_ACTIVE_LOW = Int32(1)
const IVIFGEN_VAL_AM_INTERNAL = Int32(0)
const IVIFGEN_VAL_AM_EXTERNAL = Int32(1)
const IVIFGEN_VAL_AM_SOURCE_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_AM_SOURCE_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_AM_INTERNAL_SINE = Int32(1)
const IVIFGEN_VAL_AM_INTERNAL_SQUARE = Int32(2)
const IVIFGEN_VAL_AM_INTERNAL_TRIANGLE = Int32(3)
const IVIFGEN_VAL_AM_INTERNAL_RAMP_UP = Int32(4)
const IVIFGEN_VAL_AM_INTERNAL_RAMP_DOWN = Int32(5)
const IVIFGEN_VAL_AM_INTERNAL_WFM_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_AM_INTERNAL_WFM_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_FM_INTERNAL = Int32(0)
const IVIFGEN_VAL_FM_EXTERNAL = Int32(1)
const IVIFGEN_VAL_FM_SOURCE_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_FM_SOURCE_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_FM_INTERNAL_SINE = Int32(1)
const IVIFGEN_VAL_FM_INTERNAL_SQUARE = Int32(2)
const IVIFGEN_VAL_FM_INTERNAL_TRIANGLE = Int32(3)
const IVIFGEN_VAL_FM_INTERNAL_RAMP_UP = Int32(4)
const IVIFGEN_VAL_FM_INTERNAL_RAMP_DOWN = Int32(5)
const IVIFGEN_VAL_FM_INTERNAL_WFM_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_FM_INTERNAL_WFM_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_BINARY_ALIGNMENT_LEFT = Int32(0)
const IVIFGEN_VAL_BINARY_ALIGNMENT_RIGHT = Int32(1)
const IVIFGEN_VAL_BINARY_ALIGNMENT_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_BINARY_ALIGNMENT_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_TERMINAL_CONFIGURATION_SINGLE_ENDED = Int32(0)
const IVIFGEN_VAL_TERMINAL_CONFIGURATION_DIFFERENTIAL = Int32(1)
const IVIFGEN_VAL_TERMINAL_CONFIGURATION_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_TERMINAL_CONFIGURATION_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_TRIGGER_POSITIVE = Int32(0)
const IVIFGEN_VAL_TRIGGER_NEGATIVE = Int32(1)
const IVIFGEN_VAL_TRIGGER_EITHER = Int32(2)
const IVIFGEN_VAL_TRIGGER_CLASS_EXT_BASE = Int32(500)
const IVIFGEN_VAL_TRIGGER_SPECIFIC_EXT_BASE = Int32(1000)
const IVIFGEN_VAL_ALL_WAVEFORMS = -(Int32(1))
const IVIFGEN_VAL_ALL_SEQUENCES = -(Int32(1))
const IVIFGEN_ERROR_NO_WFMS_AVAILABLE = IVI_CLASS_ERROR_BASE + Int32(4)
const IVIFGEN_ERROR_WFM_IN_USE = IVI_CLASS_ERROR_BASE + Int32(8)
const IVIFGEN_ERROR_NO_SEQS_AVAILABLE = IVI_CLASS_ERROR_BASE + Int32(9)
const IVIFGEN_ERROR_SEQ_IN_USE = IVI_CLASS_ERROR_BASE + Int32(13)
const IVIFGEN_ERROR_INVALID_WFM_CHANNEL = IVI_CLASS_ERROR_BASE + Int32(14)
const IVIFGEN_ERROR_TRIGGER_NOT_SOFTWARE = IVI_CROSS_CLASS_ERROR_BASE + Int32(1)
const IVIFGEN_ERRMSG_NO_WFMS_AVAILABLE = "The function generator's waveform memory is full."
const IVIFGEN_ERRMSG_WFM_IN_USE = "The waveform is currently in use."
const IVIFGEN_ERRMSG_NO_SEQS_AVAILABLE = "The function generator's sequence memory is full."
const IVIFGEN_ERRMSG_SEQ_IN_USE = "The sequence is currently in use."
const IVIFGEN_ERRMSG_INVALID_WFM_CHANNEL = "The waveform was created on a different channel than the one for which it is being configured."
const IVIFGEN_ERRMSG_TRIGGER_NOT_SOFTWARE = "The trigger source is not set to software trigger."

# Skipping MacroDefinition: IVIFGEN_ERROR_CODES_AND_MSGS { IVIFGEN_ERROR_NO_WFMS_AVAILABLE , IVIFGEN_ERRMSG_NO_WFMS_AVAILABLE } , { IVIFGEN_ERROR_WFM_IN_USE , IVIFGEN_ERRMSG_WFM_IN_USE } , { IVIFGEN_ERROR_NO_SEQS_AVAILABLE , IVIFGEN_ERRMSG_NO_SEQS_AVAILABLE } , { IVIFGEN_ERROR_SEQ_IN_USE , IVIFGEN_ERRMSG_SEQ_IN_USE } , { IVIFGEN_ERROR_INVALID_WFM_CHANNEL , IVIFGEN_ERRMSG_INVALID_WFM_CHANNEL } , { IVIFGEN_ERROR_TRIGGER_NOT_SOFTWARE , IVIFGEN_ERRMSG_TRIGGER_NOT_SOFTWARE }
