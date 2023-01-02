using System;

#if UNITY_EDITOR_OSX || UNITY_IOS
namespace UnityCoreBluetooth
{
    public class CoreBluetoothCharacteristic
    {
        private readonly IntPtr nativePtr;
        public CoreBluetoothCharacteristic(IntPtr ptr)
        {
            this.nativePtr = ptr;
        }

        private string _uuid = null;
        public string Uuid
        {
            get
            {
                if (_uuid == null) _uuid = NativeInterface.UcbCharacteristic.ucb_characteristic_getUuid(nativePtr);
                return _uuid;
            }
        }

        private string[] _properties = null;
        public string[] Properties
        {
            get
            {
                if (_properties == null) _properties = NativeInterface.UcbCharacteristic.ucb_characteristic_getProperties(nativePtr).Split(',');
                return _properties;
            }
        }

        public void Write(byte[] value)
        {
            NativeInterface.UcbCharacteristic.ucb_characteristic_write(nativePtr, value, value.Length);
        }

        public void SetNotifyValue(bool enable)
        {
            NativeInterface.UcbCharacteristic.ucb_characteristic_setNotify(nativePtr, enable);
        }
    }
}
#endif
