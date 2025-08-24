String createChatRoomId(String doctorId, String patientId) {
  // Alphabetical order ensure karta hai ki ID hamesha same rahe
  if (doctorId.compareTo(patientId) > 0) {
    return '${doctorId}_$patientId';
  } else {
    return '${patientId}_$doctorId';
  }
}