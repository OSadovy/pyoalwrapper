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
        eOAL_SampleFormat_Detect = 0,
        eOAL_SampleFormat_Ogg,
        eOAL_SampleFormat_Wav,
        eOAL_SampleFormat_Unknown = 0xff

    ctypedef enum eOAL_SampleFormat:
        pass

    cpdef enum eOALFilterType:
        eOALFilterType_LowPass,
        eOALFilterType_HighPass,
        eOALFilterType_BandPass,
        eOALFilterType_Null

    ctypedef enum eOALFilterType:
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


cdef extern from "OALWrapper/OAL_Filter.h":
    cdef cppclass cOAL_Filter:
        void SetType ( eOALFilterType aeType )
        void SetGain ( float afGain )
        void SetGainHF ( float afGainHF )
        void SetGainLF ( float afGainHF )
        eOALFilterType GetType ()
        float GetGain ()
        float GetGainHF()
        float GetGainLF()


cdef extern from "OALWrapper/OAL_Effect.h":
    cdef cppclass cOAL_Effect:
        pass


cdef extern from "OALWrapper/OAL_Effect_Reverb.h":
    cdef cppclass cOAL_Effect_Reverb(cOAL_Effect):
        float GetDensity( )
        float GetDiffusion ( )
        float GetGain ( )
        float GetGainHF ( )
        float GetGainLF ( )
        float GetDecayTime ( )
        float GetDecayHFRatio (  )
        float GetDecayLFRatio (  ) 
        float GetReflectionsGain (  )
        float GetReflectionsDelay(  ) 
        float* GetReflectionsPan(  )
        float GetLateReverbGain( ) 
        float GetLateReverbDelay ( )
        float* GetLateReverbPan ()
        float GetEchoTime ()
        float GetEchoDepth () 
        float GetModulationTime ()
        float GetModulationDepth ()
        float GetAirAbsorptionGainHF ()
        float GetHFReference () 
        float GetLFReference ()
        float GetRoomRolloffFactor ()
        bool GetDecayHFLimit () 

        void SetDensity( float afDensity)
        void SetDiffusion ( float afDiffusion)
        void SetGain ( float afGain)
        void SetGainHF ( float afGainHF)
        void SetGainLF ( float afGainLF)
        void SetDecayTime ( float afDecayTime)
        void SetDecayHFRatio ( float afDecayHFRatio )
        void SetDecayLFRatio ( float afDecayLFRatio )
        void SetReflectionsGain ( float afReflectionsGain )
        void SetReflectionsDelay( float afReflectionsDelay )
        void SetReflectionsPan( float afReflectionsPan[3] )
        void SetLateReverbGain( float afLateReverbGain)
        void SetLateReverbDelay ( float afLateReverbDelay)
        void SetLateReverbPan (float afLateReverbPan[3])
        void SetEchoTime (float afEchoTime)
        void SetEchoDepth (float afEchoDepth)
        void SetModulationTime (float afModulationTime)
        void SetModulationDepth (float afModulationDepth)
        void SetAirAbsorptionGainHF (float afAirAbsorptionGainHF)
        void SetHFReference (float afHFReference)
        void SetLFReference (float afLFReference)
        void SetRoomRolloffFactor (float afRoomRolloffFactor)
        void SetDecayHFLimit (bool abDecayHFLimit)


cdef extern from "OALWrapper/OAL_EFX.h":
    void OAL_Source_SetConeOuterGainHF ( const int alSourceHandle, const float afGain )
    void OAL_Source_SetAirAbsorptionFactor ( const int alSourceHandle, const float afFactor )
    void OAL_Source_SetRoomRolloffFactor ( const int alSourceHandle, const float afFactor )
    void OAL_Source_SetDirectFilterGainHFAuto ( const int alSourceHandle, bool abAuto)
    void OAL_Source_SetAuxSendFilterGainAuto ( const int alSourceHandle, bool abAuto)
    void OAL_Source_SetAuxSendFilterGainHFAuto ( const int alSourceHandle, bool abAuto)

    cOAL_Filter* OAL_Filter_Create ()
    void OAL_Filter_SetGain ( cOAL_Filter* apFilter, float afGain)
    void OAL_Filter_SetGainHF ( cOAL_Filter* apFilter, float afGainHF )
    void OAL_Filter_SetType ( cOAL_Filter* apFilter, eOALFilterType aeType )

    cOAL_Effect_Reverb*	OAL_Effect_Reverb_Create()
    void OAL_Effect_Reverb_SetDensity( cOAL_Effect_Reverb* apEffect, float afDensity)
    void OAL_Effect_Reverb_SetDiffusion ( cOAL_Effect_Reverb* apEffect, float afDiffusion)
    void OAL_Effect_Reverb_SetGain ( cOAL_Effect_Reverb* apEffect, float afGain)
    void OAL_Effect_Reverb_SetGainHF ( cOAL_Effect_Reverb* apEffect, float afGainHF)
    void OAL_Effect_Reverb_SetGainLF ( cOAL_Effect_Reverb* apEffect, float afGainLF)
    void OAL_Effect_Reverb_SetDecayTime ( cOAL_Effect_Reverb* apEffect, float afDecayTime)
    void OAL_Effect_Reverb_SetDecayHFRatio ( cOAL_Effect_Reverb* apEffect, float afDecayHFRatio )
    void OAL_Effect_Reverb_SetDecayLFRatio ( cOAL_Effect_Reverb* apEffect, float afDecayLFRatio )
    void OAL_Effect_Reverb_SetReflectionsGain ( cOAL_Effect_Reverb* apEffect, float afReflectionsGain )
    void OAL_Effect_Reverb_SetReflectionsDelay( cOAL_Effect_Reverb* apEffect, float afReflectionsDelay )
    void OAL_Effect_Reverb_SetReflectionsPan( cOAL_Effect_Reverb* apEffect, float afReflectionsPan[3] )
    void OAL_Effect_Reverb_SetLateReverbGain( cOAL_Effect_Reverb* apEffect, float afLateReverbGain)
    void OAL_Effect_Reverb_SetLateReverbDelay ( cOAL_Effect_Reverb* apEffect, float afLateReverbDelay)
    void OAL_Effect_Reverb_SetLateReverbPan (cOAL_Effect_Reverb* apEffect, float afLateReverbPan[3])
    void OAL_Effect_Reverb_SetEchoTime (cOAL_Effect_Reverb* apEffect, float afEchoTime)
    void OAL_Effect_Reverb_SetEchoDepth (cOAL_Effect_Reverb* apEffect, float afEchoDepth)
    void OAL_Effect_Reverb_SetModulationTime (cOAL_Effect_Reverb* apEffect, float afModulationTime)
    void OAL_Effect_Reverb_SetModulationDepth (cOAL_Effect_Reverb* apEffect, float afModulationDepth)
    void OAL_Effect_Reverb_SetAirAbsorptionGainHF (cOAL_Effect_Reverb* apEffect, float afAirAbsorptionGainHF)
    void OAL_Effect_Reverb_SetHFReference (cOAL_Effect_Reverb* apEffect, float afHFReference)
    void OAL_Effect_Reverb_SetLFReference (cOAL_Effect_Reverb* apEffect, float afLFReference)
    void OAL_Effect_Reverb_SetRoomRolloffFactor (cOAL_Effect_Reverb* apEffect, float afRoomRolloffFactor)
    void OAL_Effect_Reverb_SetDecayHFLimit (cOAL_Effect_Reverb* apEffect, bool abDecayHFLimit)

    void OAL_Filter_Destroy( cOAL_Filter* apFilter )
    void OAL_Effect_Destroy( cOAL_Effect* apEffect )
    int OAL_UseEffect ( cOAL_Effect* apEffect )
    bool OAL_EffectSlot_AttachEffect(int alSlotId, cOAL_Effect* apEffect)
    void OAL_EffectSlot_SetGain ( int alSlotHandle, float afGain )
    void OAL_EffectSlot_SetAutoAdjust ( int alSlotHandle, bool abAutoAdjust )
    void OAL_UpdateEffectSlots()
    void OAL_Source_SetDirectFilter( int alSourceHandle, cOAL_Filter* apFilter )
    void OAL_Source_SetAuxSend ( int alSourceHandle, int alAuxSend, int alSlotHandle, cOAL_Filter* apFilter )
    void OAL_Source_SetAuxSendSlot ( int alSourceHandle, int alAuxSend, int alSlotHandle)
    void OAL_Source_SetAuxSendFilter ( int alSourceHandle, int alAuxSend, cOAL_Filter* apFilter )
    void OAL_Source_SetFiltering( int alSourceHandle, bool abEnabled, int alFlags)
    void OAL_Source_SetFilterType( int alSourceHandle, eOALFilterType aeType)
    void OAL_Source_SetFilterGain( int alSourceHandle, float afGain)
    void OAL_Source_SetFilterGainHF( int alSourceHandle, float afGainHF)

