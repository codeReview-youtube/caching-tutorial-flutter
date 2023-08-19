const String cacheDataKey =
    'data_'; // make sure that data will not have duplicate by always setting it.
const String cacheDataExpirationKey = 'expiration_$cacheDataKey';
const String cacheDataEncryptionKey =
    'my_app_encryption_key'; // one time set && this key should private and not shared.