from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector


cdef extern from "OALWrapper/OAL_LoggerObject.h":
    cpdef enum eOAL_LogVerbose:
        eOAL_LogVerbose_None,
        eOAL_LogVerbose_Low,
        eOAL_LogVerbose_Medium,
        eOAL_LogVerbose_High,
        eOAL_LogVerbose_Default

    ctypedef enum eOAL_LogVerbose:
        pass

    cpdef enum eOAL_LogOutput:
        eOAL_LogOutput_File,
        eOAL_LogOutput_Console,
        eOAL_LogOutput_Default

    ctypedef enum eOAL_LogOutput:
        pass

cdef extern from "OALWrapper/OAL_Types.h":
    cdef int OAL_FREE
    cpdef enum eOAL_DistanceModel:
        eOAL_DistanceModel_Inverse,
        eOAL_DistanceModel_Inverse_Clamped,
        eOAL_DistanceModel_Linear,
        eOAL_DistanceModel_Linear_Clamped,
        eOAL_DistanceModel_Exponent,
        eOAL_DistanceModel_Exponent_Clamped,
        eOAL_DistanceModel_None,
        eOAL_DistanceModel_Default

    ctypedef enum eOAL_DistanceModel:
        pass

    cpdef enum eOAL_SampleFormat:
        # wrap-ignore
        eOAL_SampleFormat_Detect = 0,
        eOAL_SampleFormat_Ogg,
        eOAL_SampleFormat_Wav,
        eOAL_SampleFormat_Unknown = 0xff

    ctypedef enum eOAL_SampleFormat:
        pass


cdef extern from "OALWrapper/OAL_Init.h":
    cdef cppclass cOAL_Init_Params:
        cOAL_Init_Params() except +
        string msDeviceName
        int mlMajorVersionReq
        int mlMinorVersionReq
        int mlOutputFreq
        bool mbUseThread
        int mlUpdateFreq
        int mlNumSourcesHint
        bool mbVoiceManagement
        int mlMinMonoSourcesHint
        int mlMinStereoSourcesHint
        int mlStreamingBufferSize
        int mlStreamingBufferCount
        bool mbUseEFX
        int mlNumSlotsHint
        int mlNumSendsHint
        int mlSlotUpdateFreq

    bool    OAL_Init ( cOAL_Init_Params& acParams )
    void    OAL_Close ()
    void    OAL_Update ( )
    void OAL_SetRollOffFactor ( float afFactor)
    void OAL_SetDistanceModel ( eOAL_DistanceModel aeModel )
    const char*    OAL_Info_GetDeviceName()
    const char*    OAL_Info_GetVendorName()
    const char*    OAL_Info_GetRendererName()
    int    OAL_Info_GetMajorVersion()
    int    OAL_Info_GetMinorVersion()
    int    OAL_Info_GetNumSources()
    bool    OAL_Info_IsEFXActive()
    int OAL_Info_GetStreamBufferCount()
    int OAL_Info_GetStreamBufferSize()
    string        OAL_Info_GetDefaultOutputDevice()
    vector[string] OAL_Info_GetOutputDevices()
    void OAL_SetupLogging (bool abLogSounds, eOAL_LogOutput aeOutput, eOAL_LogVerbose aVerbose,  string asLogFilename)

cdef extern from *:
    cdef cppclass cOAL_Sample:
        pass
    cdef cppclass cOAL_Stream:
        pass

cdef extern from "OALWrapper/OAL_Loaders.h":
    cOAL_Sample* OAL_Sample_Load(string &asFilename, eOAL_SampleFormat format)
    cOAL_Sample* OAL_Sample_LoadFromBuffer (const void* apBuffer, size_t aSize, eOAL_SampleFormat format)
    void OAL_Sample_Unload(cOAL_Sample* apSample)
    cOAL_Stream* OAL_Stream_Load(string &asFilename, eOAL_SampleFormat format)
    cOAL_Stream* OAL_Stream_LoadFromBuffer(const void* apBuffer, size_t aSize, eOAL_SampleFormat format)
    void OAL_Stream_Unload(cOAL_Stream* apStream)
    void OAL_Sample_SetLoop(cOAL_Sample* apSample, bool abLoop)
    void OAL_Stream_SetLoop(cOAL_Stream* apStream, bool abLoop )
    int OAL_Sample_GetChannels(cOAL_Sample* apSample)
    int OAL_Stream_GetChannels(cOAL_Stream* apStream)


cdef extern from "OALWrapper/OAL_Playback.h":
    int OAL_Sample_Play(int alSource, cOAL_Sample* apSample, float afVolume, bool abStartPaused , int alPriority)
    int OAL_Stream_Play(int alSource, cOAL_Stream* apStream, float afVolume, bool abStartPaused)

    void OAL_Source_Stop(int alSource)
    void OAL_Source_SetPaused(int alSource, const bool abPaused)
    void OAL_Source_SetGain(int alSource, float afVolume)
    void OAL_Source_SetPitch(int alSource, float afPitch)
    void OAL_Source_SetLoop(int alSource, const bool abLoop)
    void OAL_Source_SetPosition(const int alSource, const float* apPos)
    void OAL_Source_SetVelocity(const int alSource, const float* apVel)
    void OAL_Source_SetAttributes(const int alSource, const float* apPos, const float* apVel)
    void OAL_Source_SetMinMaxDistance(const int alSource, const float afMin, const float afMax)
    void OAL_Source_SetPositionRelative(const int alSource, const bool abRelative)
    void OAL_Source_SetPriority(const int alSource, const unsigned int alPriority)
    void OAL_Source_SetConeOuterGain ( const int alSource, const float afGain )
    void OAL_Source_setConeInnerAngle ( const int alSource, const float afAngle )
    void OAL_Source_setConeOuterAngle ( const int alSource, const float afAngle )
    void OAL_Source_SetDirection ( const int alSource, const float* apDir )

    unsigned int OAL_Source_GetPriority(const int alSource)
    float OAL_Source_GetPitch(const int alSource)
    float OAL_Source_GetGain(const int alSource)
    const bool OAL_Source_IsPlaying(const int alSource)
    const bool OAL_Source_IsBufferUnderrun(const int alSource)

    void OAL_Listener_SetAttributes(const float* apPos, const float* apVel, const float* apForward, const float* apUpward)
    void OAL_Listener_SetMasterVolume(const float afVolume)

    void OAL_Source_SetElapsedTime(const int alSource, double afTime)
    double OAL_Source_GetElapsedTime(const int alSource)
    double OAL_Source_GetTotalTime(const int alSource)

cdef extern from "OALWrapper/OAL_Device.h":
    cdef cppclass cOAL_Device:
        inline int GetEFXSends()
        void SetListenerGain ( const float afGain )
        void SetListenerPosition (const float* apPos )
        void SetListenerVelocity (const float* apVel )
        void SetListenerOrientation (const float* apForward, const float* apUp)


cdef extern from "OALWrapper/OAL_EFX.h":
    void OAL_Source_SetConeOuterGainHF ( const int alSourceHandle, const float afGain )
    void OAL_Source_SetAirAbsorptionFactor ( const int alSourceHandle, const float afFactor )
    void OAL_Source_SetRoomRolloffFactor ( const int alSourceHandle, const float afFactor )
    void OAL_Source_SetDirectFilterGainHFAuto ( const int alSourceHandle, bool abAuto)
    void OAL_Source_SetAuxSendFilterGainAuto ( const int alSourceHandle, bool abAuto)
    void OAL_Source_SetAuxSendFilterGainHFAuto ( const int alSourceHandle, bool abAuto)
