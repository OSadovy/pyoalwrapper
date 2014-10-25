#distutils: language = c++

from pyoalwrapper cimport *


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

    property use_e_f_x:
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
