#distutils: language = c++

cimport cython
from pyoalwrapper cimport *
cimport efxpresets


cdef extern from "helper.h":
    cdef cOAL_Device* gpDevice


cdef class InitParams:
    cdef cOAL_Init_Params params

    property device_name:
        def __get__(self): return self.params.msDeviceName
        def __set__(self, string v): self.params.msDeviceName = v

    property major_version_req:
        def __get__(self): return self.params.mlMajorVersionReq
        def __set__(self, int v): self.params.mlMajorVersionReq = v

    property minor_version_req:
        def __get__(self): return self.params.mlMinorVersionReq
        def __set__(self, int v): self.params.mlMinorVersionReq = v

    property output_freq:
        def __get__(self): return self.params.mlOutputFreq
        def __set__(self, int v): self.params.mlOutputFreq = v

    property use_thread:
        def __get__(self): return self.params.mbUseThread
        def __set__(self, bool v): self.params.mbUseThread = v

    property update_freq:
        def __get__(self): return self.params.mlUpdateFreq
        def __set__(self, int v): self.params.mlUpdateFreq = v

    property num_sources_hint:
        def __get__(self): return self.params.mlNumSourcesHint
        def __set__(self, int v): self.params.mlNumSourcesHint = v

    property voice_management:
        def __get__(self): return self.params.mbVoiceManagement
        def __set__(self, bool v): self.params.mbVoiceManagement = v

    property min_mono_sources_hint:
        def __get__(self): return self.params.mlMinMonoSourcesHint
        def __set__(self, int v): self.params.mlMinMonoSourcesHint = v

    property min_stereo_sources_hint:
        def __get__(self): return self.params.mlMinStereoSourcesHint
        def __set__(self, int v): self.params.mlMinStereoSourcesHint = v

    property streaming_buffer_size:
        def __get__(self): return self.params.mlStreamingBufferSize
        def __set__(self, int v): self.params.mlStreamingBufferSize = v

    property streaming_buffer_count:
        def __get__(self): return self.params.mlStreamingBufferCount
        def __set__(self, int v): self.params.mlStreamingBufferCount = v

    property use_efx:
        def __get__(self): return self.params.mbUseEFX
        def __set__(self, bool v): self.params.mbUseEFX = v

    property num_slots_hint:
        def __get__(self): return self.params.mlNumSlotsHint
        def __set__(self, int v): self.params.mlNumSlotsHint = v

    property num_sends_hint:
        def __get__(self): return self.params.mlNumSendsHint
        def __set__(self, int v): self.params.mlNumSendsHint = v

    property slot_update_freq:
        def __get__(self): return self.params.mlSlotUpdateFreq
        def __set__(self, int v): self.params.mlSlotUpdateFreq = v


def init(InitParams params=None):
    if params is None:
        params = InitParams()
    return OAL_Init(params.params)

def close():
    OAL_Close()

def update():
    OAL_Update()

def set_roll_off_factor(float afFactor):
    OAL_SetRollOffFactor(afFactor)

def set_distance_model(eOAL_DistanceModel aeModel):
    OAL_SetDistanceModel(aeModel)

def get_device_name():
    return OAL_Info_GetDeviceName()

def get_vendor_name():
    return OAL_Info_GetVendorName()

def get_renderer_name():
    return OAL_Info_GetRendererName()

def get_major_version():
    return OAL_Info_GetMajorVersion()

def get_minor_version():
    return OAL_Info_GetMinorVersion()

def get_num_sources():
    return OAL_Info_GetNumSources()

def is_efx_active():
    return OAL_Info_IsEFXActive()

def get_stream_buffer_count():
    return OAL_Info_GetStreamBufferCount()

def get_stream_buffer_size():
    return OAL_Info_GetStreamBufferSize()

def get_default_output_device():
    return OAL_Info_GetDefaultOutputDevice()

def get_output_devices():
    return OAL_Info_GetOutputDevices()

def get_EFX_sends():
    if gpDevice is not NULL:
        return gpDevice.GetEFXSends()

def setup_logging(bool abLogSounds, eOAL_LogOutput aeOutput, eOAL_LogVerbose aVerbose, string asLogFilename):
    OAL_SetupLogging(abLogSounds, aeOutput, aVerbose, asLogFilename)


cdef class Sample:
    cdef cOAL_Sample* inst
    def __dealloc__(self):
        if self.inst is not NULL:
            OAL_Sample_Unload(self.inst)
            self.inst = NULL

    @classmethod
    def load(cls,  asFilename, eOAL_SampleFormat format=eOAL_SampleFormat_Detect):
        cdef Sample r = cls.__new__(cls)
        r.inst = OAL_Sample_Load(<string>asFilename, format)
        if r.inst is NULL:
            raise RuntimeError("Error loading sample from file")
        return r

    @classmethod
    def load_from_buffer(cls,  unsigned char[:] buffer, eOAL_SampleFormat format=eOAL_SampleFormat_Detect):
        cdef Sample r = cls.__new__(cls)
        r.inst = OAL_Sample_LoadFromBuffer(&buffer[0], buffer.shape[0], format)
        if r.inst is NULL:
            raise RuntimeError("Error loading sample from buffer")
        return r

    def set_loop(self, bool loop):
        OAL_Sample_SetLoop(self.inst, loop)

    def get_channels(self):
        return OAL_Sample_GetChannels(self.inst)

    def play(self, Source source=None, float volume=1.0, bool start_paused=False, int priority=1):
        cdef int handle
        if source is None:
            handle = OAL_FREE
        else:
            handle = source.handle
        handle = OAL_Sample_Play(handle, self.inst, volume, start_paused, priority)
        if handle == -1:
            raise RuntimeError("Error playing sample: %d" % handle)
        if source is None:
            source = Source.__new__(Source)
        source.handle = handle
        return source


cdef class Stream:
    cdef cOAL_Stream* inst
    def __dealloc__(self):
        if self.inst is not NULL:
            OAL_Stream_Unload(self.inst)
            self.inst = NULL

    @classmethod
    def load(cls,  asFilename, eOAL_SampleFormat format=eOAL_SampleFormat_Detect):
        cdef Stream r = cls.__new__(cls)
        r.inst = OAL_Stream_Load(<string>asFilename, format)
        if r.inst is NULL:
            raise RuntimeError("Error loading stream from file")
        return r

    @classmethod
    def load_from_buffer(cls,  unsigned char[:] buffer, eOAL_SampleFormat format=eOAL_SampleFormat_Detect):
        cdef Stream r = cls.__new__(cls)
        r.inst = OAL_Stream_LoadFromBuffer(&buffer[0], buffer.shape[0], format)
        if r.inst is NULL:
            raise RuntimeError("Error loading stream from buffer")
        return r

    def set_loop(self, bool loop):
        OAL_Stream_SetLoop(self.inst, loop)

    def get_channels(self):
        return OAL_Stream_GetChannels(self.inst)

    def play(self, Source source=None, float volume=1.0, bool start_paused=False):
        cdef int handle
        if source is None:
            handle = OAL_FREE
        else:
            handle = source.handle
        handle = OAL_Stream_Play(handle, self.inst, volume, start_paused)
        if handle == -1:
            raise RuntimeError("Error playing stream: %d" % handle)
        if source is None:
            source = Source.__new__(Source)
        source.handle = handle
        return source


cdef class Source:
    cdef int handle
    def stop(self):
        OAL_Source_Stop(self.handle)

    def set_paused(self, bool paused):
        OAL_Source_SetPaused(self.handle, paused)

    def set_gain(self, float volume):
        OAL_Source_SetGain(self.handle, volume)

    def set_pitch(self, float pitch):
        OAL_Source_SetPitch(self.handle, pitch)

    def set_loop(self, bool loop):
        OAL_Source_SetLoop(self.handle, loop)

    def set_position(self, float x, float y, float z):
        cdef float[3] pos
        pos[0] = x
        pos[1] = y
        pos[2] = z
        OAL_Source_SetPosition(self.handle, pos)

    def set_velocity(self, float x, float y, float z):
        cdef float[3] vel
        vel[0] = x
        vel[1] = y
        vel[2] = z
        OAL_Source_SetVelocity(self.handle, vel)

    def set_attributes(self, pos, vel):
        cdef float[3] _pos
        _pos[0] = pos[0];_pos[1]=pos[1];_pos[2]=pos[2]
        cdef float[3] _vel
        _vel[0] = vel[0];_vel[1]=vel[1];_vel[2]=vel[2]
        OAL_Source_SetAttributes(self.handle, _pos, _vel)

    def set_min_max_distance(self, float min, float max):
        OAL_Source_SetMinMaxDistance(self.handle, min, max)

    def set_position_relative(self, bool relative):
        OAL_Source_SetPositionRelative(self.handle, relative)

    def set_priority(self, unsigned int priority):
        OAL_Source_SetPriority(self.handle, priority)

    def get_priority(self):
        return OAL_Source_GetPriority(self.handle)

    def get_pitch(self):
        return OAL_Source_GetPitch(self.handle)

    def get_gain(self):
        return OAL_Source_GetGain(self.handle)

    def is_playing(self):
        return OAL_Source_IsPlaying(self.handle)

    def is_buffer_underrun(self):
        return OAL_Source_IsBufferUnderrun(self.handle)

    def set_elapsed_time(self, double time):
        OAL_Source_SetElapsedTime(self.handle, time)

    def get_elapsed_time(self):
        return OAL_Source_GetElapsedTime(self.handle)

    def get_total_time(self):
        return OAL_Source_GetTotalTime(self.handle)

    def set_cone_outer_gain(self, float gain):
        OAL_Source_SetConeOuterGain(self.handle, gain)

    def _set_cone_inner_angle(self, float angle):
        OAL_Source_setConeInnerAngle(self.handle, angle)

    def _set_cone_outer_angle(self, float angle):
        OAL_Source_setConeOuterAngle(self.handle, angle)

    def set_direction(self, float x, float y, float z):
        cdef float[3] dir
        dir[0] = x
        dir[1] = y
        dir[2] = z
        OAL_Source_SetDirection(self.handle, dir)

    def set_cone_outer_gain_hf(self, float gain):
        OAL_Source_SetConeOuterGainHF(self.handle, gain)

    def set_air_absorption_factor(self, float factor):
        OAL_Source_SetAirAbsorptionFactor(self.handle, factor)

    def set_room_rolloff_factor(self, float factor):
        OAL_Source_SetRoomRolloffFactor(self.handle, factor)

    def set_direct_filter_gain_hf_auto(self, bool auto):
        OAL_Source_SetDirectFilterGainHFAuto(self.handle, auto)

    def set_aux_send_filter_gain_auto(self, bool auto):
        OAL_Source_SetAuxSendFilterGainAuto(self.handle, auto)

    def set_aux_send_filter_gain_hf_auto(self, bool auto):
        OAL_Source_SetAuxSendFilterGainHFAuto(self.handle, auto)

    def set_direct_filter(self, Filter filter):
        if filter is not None:
            OAL_Source_SetDirectFilter(self.handle, filter.filter)
        else:
            OAL_Source_SetDirectFilter(self.handle, NULL)

    def set_aux_send(self, int send, EffectSlot slot, Filter filter=None):
        OAL_Source_SetAuxSend(self.handle, send, slot.slot if slot is not None else -1, filter.filter if filter is not None else NULL)

    def set_aux_send_slot(self, int send, EffectSlot slot):
        OAL_Source_SetAuxSendSlot(self.handle, send, slot.slot if slot is not None else -1)

    def set_aux_send_filter(self, int send, Filter filter):
        OAL_Source_SetAuxSendFilter(self.handle, send, filter.filter if filter is not None else NULL)


cdef class Filter:
    cdef cOAL_Filter* filter
    def __cinit__(self, eOALFilterType filter_type):
        self.filter = OAL_Filter_Create()
        if self.filter is NULL:
            raise RuntimeError("Error creating filter")
        OAL_Filter_SetType(self.filter, filter_type)

    def __dealloc__(self):
        if self.filter is not NULL:
            OAL_Filter_Destroy(self.filter)
            self.filter = NULL

    property gain:
        def __get__(self): return self.filter.GetGain()
        def __set__(self, float gain): self.filter.SetGain(gain)

    property gain_hf:
        def __get__(self): return self.filter.GetGainHF()
        def __set__(self, float gain_hf): self.filter.SetGainHF(gain_hf)

    property gain_lf:
        def __get__(self): return self.filter.GetGainLF()
        def __set__(self, float gain_lf): self.filter.SetGainLF(gain_lf)


@cython.internal
cdef class Effect:
    cdef cOAL_Effect* inst


cdef class ReverbEffect(Effect):
    def __cinit__(self):
        self.inst = OAL_Effect_Reverb_Create()
        if self.inst is NULL:
            raise RuntimeError("Error creating reverb effect")

    def __dealloc__(self):
        if self.inst is not NULL:
            OAL_Effect_Destroy(self.inst)
            self.inst = NULL

    property density:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetDensity()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetDensity(v)

    property diffusion:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetDiffusion()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetDiffusion(v)

    property gain:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetGain()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetGain(v)

    property gain_hf:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetGainHF()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetGainHF(v)

    property gain_lf:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetGainLF()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetGainLF(v)

    property decay_time:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetDecayTime()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetDecayTime(v)

    property decay_hf_ratio:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetDecayHFRatio()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetDecayHFRatio(v)

    property decay_lf_ratio:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetDecayLFRatio()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetDecayLFRatio(v)

    property reflections_gain:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetReflectionsGain()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetReflectionsGain(v)

    property reflections_delay:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetReflectionsDelay()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetReflectionsDelay(v)

    property reflections_pan:
        def __get__(self):
            cdef float* pan = (<cOAL_Effect_Reverb*>self.inst).GetReflectionsPan()
            return pan[0], pan[1], pan[2]
        def __set__(self, v):
            cdef float[3] pan
            pan[0], pan[1], pan[2] = v
            (<cOAL_Effect_Reverb*>self.inst).SetReflectionsPan(pan)

    property late_reverb_gain:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetLateReverbGain()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetLateReverbGain(v)

    property late_reverb_delay:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetLateReverbDelay()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetLateReverbDelay(v)

    property late_reverb_pan:
        def __get__(self):
            cdef float* pan = (<cOAL_Effect_Reverb*>self.inst).GetLateReverbPan()
            return pan[0], pan[1], pan[2]
        def __set__(self, v):
            cdef float[3] pan
            pan[0], pan[1], pan[2] = v
            (<cOAL_Effect_Reverb*>self.inst).SetLateReverbPan(pan)

    property echo_time:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetEchoTime()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetEchoTime(v)

    property echo_depth:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetEchoDepth()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetEchoDepth(v)

    property modulation_time:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetModulationTime()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetModulationTime(v)

    property modulation_depth:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetModulationDepth()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetModulationDepth(v)

    property air_absorption_gain_hf:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetAirAbsorptionGainHF()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetAirAbsorptionGainHF(v)

    property hf_reference:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetHFReference()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetHFReference(v)

    property lf_reference:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetLFReference()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetLFReference(v)

    property room_rolloff_factor:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetRoomRolloffFactor()
        def __set__(self, float v): (<cOAL_Effect_Reverb*>self.inst).SetRoomRolloffFactor(v)

    property decay_hf_limit:
        def __get__(self): return (<cOAL_Effect_Reverb*>self.inst).GetDecayHFLimit()
        def __set__(self, bool v): (<cOAL_Effect_Reverb*>self.inst).SetDecayHFLimit(v)

    cdef apply_preset(self, efxpresets.EFXEAXREVERBPROPERTIES props):
        (<cOAL_Effect_Reverb*>self.inst).SetDensity(props.flDensity)
        (<cOAL_Effect_Reverb*>self.inst).SetDiffusion(props.flDiffusion)
        (<cOAL_Effect_Reverb*>self.inst).SetGain(props.flGain)
        (<cOAL_Effect_Reverb*>self.inst).SetGainHF(props.flGainHF)
        (<cOAL_Effect_Reverb*>self.inst).SetGainLF(props.flGainLF)
        (<cOAL_Effect_Reverb*>self.inst).SetDecayTime(props.flDecayTime)
        (<cOAL_Effect_Reverb*>self.inst).SetDecayHFRatio(props.flDecayHFRatio)
        (<cOAL_Effect_Reverb*>self.inst).SetDecayLFRatio(props.flDecayLFRatio)
        (<cOAL_Effect_Reverb*>self.inst).SetReflectionsGain(props.flReflectionsGain)
        (<cOAL_Effect_Reverb*>self.inst).SetReflectionsDelay(props.flReflectionsDelay)
        (<cOAL_Effect_Reverb*>self.inst).SetReflectionsPan(props.flReflectionsPan)
        (<cOAL_Effect_Reverb*>self.inst).SetLateReverbGain(props.flLateReverbGain)
        (<cOAL_Effect_Reverb*>self.inst).SetLateReverbDelay(props.flLateReverbDelay)
        (<cOAL_Effect_Reverb*>self.inst).SetLateReverbPan(props.flLateReverbPan)
        (<cOAL_Effect_Reverb*>self.inst).SetEchoTime(props.flEchoTime)
        (<cOAL_Effect_Reverb*>self.inst).SetEchoDepth(props.flEchoDepth)
        (<cOAL_Effect_Reverb*>self.inst).SetModulationTime(props.flModulationTime)
        (<cOAL_Effect_Reverb*>self.inst).SetModulationDepth(props.flModulationDepth)
        (<cOAL_Effect_Reverb*>self.inst).SetAirAbsorptionGainHF(props.flAirAbsorptionGainHF)
        (<cOAL_Effect_Reverb*>self.inst).SetHFReference(props.flHFReference)
        (<cOAL_Effect_Reverb*>self.inst).SetLFReference(props.flLFReference)
        (<cOAL_Effect_Reverb*>self.inst).SetRoomRolloffFactor(props.flRoomRolloffFactor)
        (<cOAL_Effect_Reverb*>self.inst).SetDecayHFLimit(props.iDecayHFLimit)

    def load_preset(self, str preset):
        if preset == 'GENERIC':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_GENERIC())
        elif preset == 'PADDEDCELL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PADDEDCELL())
        elif preset == 'ROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ROOM())
        elif preset == 'BATHROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_BATHROOM())
        elif preset == 'LIVINGROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_LIVINGROOM())
        elif preset == 'STONEROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_STONEROOM())
        elif preset == 'AUDITORIUM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_AUDITORIUM())
        elif preset == 'CONCERTHALL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CONCERTHALL())
        elif preset == 'CAVE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CAVE())
        elif preset == 'ARENA':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ARENA())
        elif preset == 'HANGAR':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_HANGAR())
        elif preset == 'CARPETEDHALLWAY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CARPETEDHALLWAY())
        elif preset == 'HALLWAY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_HALLWAY())
        elif preset == 'STONECORRIDOR':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_STONECORRIDOR())
        elif preset == 'ALLEY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ALLEY())
        elif preset == 'FOREST':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FOREST())
        elif preset == 'CITY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CITY())
        elif preset == 'MOUNTAINS':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_MOUNTAINS())
        elif preset == 'QUARRY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_QUARRY())
        elif preset == 'PLAIN':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PLAIN())
        elif preset == 'PARKINGLOT':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PARKINGLOT())
        elif preset == 'SEWERPIPE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SEWERPIPE())
        elif preset == 'UNDERWATER':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_UNDERWATER())
        elif preset == 'DRUGGED':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRUGGED())
        elif preset == 'DIZZY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DIZZY())
        elif preset == 'PSYCHOTIC':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PSYCHOTIC())
        elif preset == 'CASTLE_SMALLROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_SMALLROOM())
        elif preset == 'CASTLE_SHORTPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_SHORTPASSAGE())
        elif preset == 'CASTLE_MEDIUMROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_MEDIUMROOM())
        elif preset == 'CASTLE_LARGEROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_LARGEROOM())
        elif preset == 'CASTLE_LONGPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_LONGPASSAGE())
        elif preset == 'CASTLE_HALL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_HALL())
        elif preset == 'CASTLE_CUPBOARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_CUPBOARD())
        elif preset == 'CASTLE_COURTYARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_COURTYARD())
        elif preset == 'CASTLE_ALCOVE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CASTLE_ALCOVE())
        elif preset == 'FACTORY_SMALLROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_SMALLROOM())
        elif preset == 'FACTORY_SHORTPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_SHORTPASSAGE())
        elif preset == 'FACTORY_MEDIUMROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_MEDIUMROOM())
        elif preset == 'FACTORY_LARGEROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_LARGEROOM())
        elif preset == 'FACTORY_LONGPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_LONGPASSAGE())
        elif preset == 'FACTORY_HALL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_HALL())
        elif preset == 'FACTORY_CUPBOARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_CUPBOARD())
        elif preset == 'FACTORY_COURTYARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_COURTYARD())
        elif preset == 'FACTORY_ALCOVE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_FACTORY_ALCOVE())
        elif preset == 'ICEPALACE_SMALLROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_SMALLROOM())
        elif preset == 'ICEPALACE_SHORTPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_SHORTPASSAGE())
        elif preset == 'ICEPALACE_MEDIUMROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_MEDIUMROOM())
        elif preset == 'ICEPALACE_LARGEROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_LARGEROOM())
        elif preset == 'ICEPALACE_LONGPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_LONGPASSAGE())
        elif preset == 'ICEPALACE_HALL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_HALL())
        elif preset == 'ICEPALACE_CUPBOARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_CUPBOARD())
        elif preset == 'ICEPALACE_COURTYARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_COURTYARD())
        elif preset == 'ICEPALACE_ALCOVE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_ICEPALACE_ALCOVE())
        elif preset == 'SPACESTATION_SMALLROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPACESTATION_SMALLROOM())
        elif preset == 'SPACESTATION_SHORTPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPACESTATION_SHORTPASSAGE())
        elif preset == 'SPACESTATION_MEDIUMROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPACESTATION_MEDIUMROOM())
        elif preset == 'SPACESTATION_LARGEROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPACESTATION_LARGEROOM())
        elif preset == 'SPACESTATION_LONGPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPACESTATION_LONGPASSAGE())
        elif preset == 'SPACESTATION_HALL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPACESTATION_HALL())
        elif preset == 'SPACESTATION_CUPBOARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPACESTATION_CUPBOARD())
        elif preset == 'SPACESTATION_ALCOVE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPACESTATION_ALCOVE())
        elif preset == 'WOODEN_SMALLROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_SMALLROOM())
        elif preset == 'WOODEN_SHORTPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_SHORTPASSAGE())
        elif preset == 'WOODEN_MEDIUMROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_MEDIUMROOM())
        elif preset == 'WOODEN_LARGEROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_LARGEROOM())
        elif preset == 'WOODEN_LONGPASSAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_LONGPASSAGE())
        elif preset == 'WOODEN_HALL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_HALL())
        elif preset == 'WOODEN_CUPBOARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_CUPBOARD())
        elif preset == 'WOODEN_COURTYARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_COURTYARD())
        elif preset == 'WOODEN_ALCOVE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_WOODEN_ALCOVE())
        elif preset == 'SPORT_EMPTYSTADIUM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPORT_EMPTYSTADIUM())
        elif preset == 'SPORT_SQUASHCOURT':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPORT_SQUASHCOURT())
        elif preset == 'SPORT_SMALLSWIMMINGPOOL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPORT_SMALLSWIMMINGPOOL())
        elif preset == 'SPORT_LARGESWIMMINGPOOL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPORT_LARGESWIMMINGPOOL())
        elif preset == 'SPORT_GYMNASIUM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPORT_GYMNASIUM())
        elif preset == 'SPORT_FULLSTADIUM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPORT_FULLSTADIUM())
        elif preset == 'SPORT_STADIUMTANNOY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SPORT_STADIUMTANNOY())
        elif preset == 'PREFAB_WORKSHOP':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PREFAB_WORKSHOP())
        elif preset == 'PREFAB_SCHOOLROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PREFAB_SCHOOLROOM())
        elif preset == 'PREFAB_PRACTISEROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PREFAB_PRACTISEROOM())
        elif preset == 'PREFAB_OUTHOUSE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PREFAB_OUTHOUSE())
        elif preset == 'PREFAB_CARAVAN':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PREFAB_CARAVAN())
        elif preset == 'DOME_TOMB':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DOME_TOMB())
        elif preset == 'PIPE_SMALL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PIPE_SMALL())
        elif preset == 'DOME_SAINTPAULS':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DOME_SAINTPAULS())
        elif preset == 'PIPE_LONGTHIN':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PIPE_LONGTHIN())
        elif preset == 'PIPE_LARGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PIPE_LARGE())
        elif preset == 'PIPE_RESONANT':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_PIPE_RESONANT())
        elif preset == 'OUTDOORS_BACKYARD':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_OUTDOORS_BACKYARD())
        elif preset == 'OUTDOORS_ROLLINGPLAINS':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_OUTDOORS_ROLLINGPLAINS())
        elif preset == 'OUTDOORS_DEEPCANYON':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_OUTDOORS_DEEPCANYON())
        elif preset == 'OUTDOORS_CREEK':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_OUTDOORS_CREEK())
        elif preset == 'OUTDOORS_VALLEY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_OUTDOORS_VALLEY())
        elif preset == 'MOOD_HEAVEN':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_MOOD_HEAVEN())
        elif preset == 'MOOD_HELL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_MOOD_HELL())
        elif preset == 'MOOD_MEMORY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_MOOD_MEMORY())
        elif preset == 'DRIVING_COMMENTATOR':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRIVING_COMMENTATOR())
        elif preset == 'DRIVING_PITGARAGE':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRIVING_PITGARAGE())
        elif preset == 'DRIVING_INCAR_RACER':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRIVING_INCAR_RACER())
        elif preset == 'DRIVING_INCAR_SPORTS':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRIVING_INCAR_SPORTS())
        elif preset == 'DRIVING_INCAR_LUXURY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRIVING_INCAR_LUXURY())
        elif preset == 'DRIVING_FULLGRANDSTAND':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRIVING_FULLGRANDSTAND())
        elif preset == 'DRIVING_EMPTYGRANDSTAND':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRIVING_EMPTYGRANDSTAND())
        elif preset == 'DRIVING_TUNNEL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DRIVING_TUNNEL())
        elif preset == 'CITY_STREETS':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CITY_STREETS())
        elif preset == 'CITY_SUBWAY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CITY_SUBWAY())
        elif preset == 'CITY_MUSEUM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CITY_MUSEUM())
        elif preset == 'CITY_LIBRARY':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CITY_LIBRARY())
        elif preset == 'CITY_UNDERPASS':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CITY_UNDERPASS())
        elif preset == 'CITY_ABANDONED':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CITY_ABANDONED())
        elif preset == 'DUSTYROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_DUSTYROOM())
        elif preset == 'CHAPEL':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_CHAPEL())
        elif preset == 'SMALLWATERROOM':
            self.apply_preset(efxpresets.get_EFX_REVERB_PRESET_SMALLWATERROOM())
        else:
            raise ValueError("Argument should be either effect or int")


cdef class EffectSlot:
    cdef int slot
    def __cinit__(self, effect_or_slot_num):
        if isinstance(effect_or_slot_num, Effect):
            self.slot = OAL_UseEffect((<Effect>effect_or_slot_num).inst)
            if self.slot == -1:
                raise RuntimeError("Can not create effect slot from effect")
        elif isinstance(effect_or_slot_num, int):
            self.slot = effect_or_slot_num
        else:
            raise ValueError("Argument should be either effect or int")

    def set_gain(self, float gain):
        OAL_EffectSlot_SetGain(self.slot, gain)

    def set_autoadjust(self, bool auto):
        OAL_EffectSlot_SetAutoAdjust(self.slot, auto)

    def attach_effect(self, Effect effect):
        if effect is not None:
            return OAL_EffectSlot_AttachEffect(self.slot, effect.inst)
        else:
            return OAL_EffectSlot_AttachEffect(self.slot, NULL)

    def __dealloc__(self):
        if self.slot != -1:
            OAL_EffectSlot_AttachEffect(self.slot, NULL)


def update_effect_slots():
    OAL_UpdateEffectSlots()

def set_listener_gain(float gain):
    if gpDevice is not NULL:
        gpDevice.SetListenerGain(gain)

def set_listener_position(float x, float y, float z):
    cdef float[3] pos
    if gpDevice is not NULL:
        pos[0] = x
        pos[1] = y
        pos[2] = z
        gpDevice.SetListenerPosition(pos)

def set_listener_velocity(float x, float y, float z):
    cdef float[3] vel
    if gpDevice is not NULL:
        vel[0] = x
        vel[1] = y
        vel[2] = z
        gpDevice.SetListenerVelocity(vel)

def set_listener_orientation(forward, up):
    cdef float[3] f
    cdef float[3] u
    if gpDevice is not NULL:
        f[0] = forward[0];f[1] = forward[1];f[2] = forward[2]
        u[0] = up[0];u[1] = up[1];u[2] = up[2]
        gpDevice.SetListenerOrientation(f, u)
