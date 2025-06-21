import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale('en', LocaleData.EN),
  MapLocale('ro', LocaleData.RO),
];

mixin LocaleData {
  static const String title = 'title';
  static const String welcome = 'welcome';
  static const String loginToContinue = 'loginToContinue';
  static const String login = 'login';
  static const String password = 'password';
  static const String rememberMe = 'rememberMe';
  static const String emailValidationError = 'emailValidationError';
  static const String passwordValidationError = 'passwordValidationError';
  static const String registerNewAccount = 'registerNewAccount';
  static const String register = 'register';
  static const String phoneNumber = 'phoneNumber';
  static const String city = 'city';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String selectDate = 'selectDate';
  static const String birthDate = 'birthDate';
  static const String selectUserType = 'selectUserType';
  static const String patient = 'patient';
  static const String selectedDate = 'selectedDate';
  static const String phoneNumberValidationError = 'phoneNumberValidationError';
  static const String firstNameValidationError = 'firstNameValidationError';
  static const String lastNameValidationError = 'lastNameValidationError';
  static const String cnpValidationError = 'cnpValidationError';
  static const String cityValidationError = 'cityValidationError';
  static const String legitimationNumber = 'legitimationNumber';
  static const String legitimationNumberValidationError = 'legitimationNumberValidationError';
  static const String pickCv = 'pickCv';
  static const String pickCvValidationError = 'pickCvValidationError';
  static const String alreadyHaveAnAccount = 'alreadyHaveAnAccount';
  static const String numberOfPatients = 'numberOfPatients';
  static const String capacity = 'capacity';
  static const String address = 'address';
  static const String workingHours = 'workingHours';
  static const String patientList = 'patientList';
  static const String emergencies = 'emergencies';
  static const String editCabinet = 'editCabinet';
  static const String registrationRequests = 'registrationRequests';
  static const String dateOfRequest = 'dateOfRequest';
  static const String accept = 'accept';
  static const String reject = 'reject';
  static const String noRequests = 'noRequests';
  static const String noPatients = 'noPatients';
  static const String noEmergencies = 'noEmergencies';
  static const String patientName = 'patientName';
  static const String patientPhone = 'patientPhone';
  static const String bookAppointment = 'bookAppointment';
  static const String noAvailableSlots = 'noAvailableSlots';
  static const String selectedTime = 'selectedTime';
  static const String description = 'description';
  static const String generateReport = 'generateReport';
  static const String bookings = 'bookings';
  static const String noBookings = 'noBookings';
  static const String acceptingPatients = 'acceptingPatients';
  static const String notAcceptingPatients = 'notAcceptingPatients';
  static const String sendRequestToRegister = 'sendRequestToRegister';
  static const String call = 'call';
  static const String message = 'message';
  static const String viewDoctorProfile = 'viewDoctorProfile';
  static const String viewDetails = 'viewDetails';
  static const String cabinetMap = 'cabinetMap';
  static const String registerCabinet = 'registerCabinet';
  static const String cabinetName = 'cabinetName';
  static const String cabinetNameValidationError = 'cabinetNameValidationError';
  static const String capacityValidationError = 'capacityValidationError';
  static const String openingTime = 'openingTime';
  static const String closingTime = 'closingTime';
  static const String openingTimeValidationError = 'openingTimeValidationError';
  static const String closingTimeValidationError = 'closingTimeValidationError';
  static const String pickImage = 'pickImage';
  static const String openMap = 'openMap';
  static const String chooseLocation = 'chooseLocation';
  static const String location = 'location';
  static const String coordinates = 'coordinates';
  static const String addMedicalHistoryTitle = 'addMedicalHistoryTitle';
  static const String resultsLabel = 'resultsLabel';
  static const String recommendationsLabel = 'recommendationsLabel';
  static const String addAnalysisLabel = 'addAnalysisLabel';
  static const String saveButton = 'saveButton';
  static const String errorCouldNotSaveMedicalHistory = 'errorCouldNotSaveMedicalHistory';
  static const String selectTimeSlotTitle = 'selectTimeSlotTitle';
  static const String okButton = 'okButton';
  static const String bookingSuccessful = 'bookingSuccessful';
  static const String bookingFailed = 'bookingFailed';
  static const String unknownPatient = 'unknownPatient';
  static const String errorFetchingPatientName = 'errorFetchingPatientName';
  static const String loadingText = 'loadingText';
  static const String confirmButton = 'confirmButton';
  static const String completeButton = 'completeButton';
  static const String contactDoctorLabel = 'contactDoctorLabel';
  static const String registrationRequestSentSuccess = 'registrationRequestSentSuccess';
  static const String registrationRequestFailed = 'registrationRequestFailed';
  static const String couldNotCall = 'couldNotCall';
  static const String googleMapsTitle = 'googleMapsTitle';
  static const String selectButton = 'selectButton';
  static const String failedToSelectLocation = 'failedToSelectLocation';
  static const String chatListTitle = 'chatListTitle';
  static const String couldNotGetChats = 'couldNotGetChats';
  static const String chatWithPrefix = 'chatWithPrefix'; 
  static const String noMessagesYet = 'noMessagesYet';
  static const String typeAMessageHint = 'typeAMessageHint';
  static const String loadingCabinet = 'loadingCabinet';
  static const String errorLoadingCabinet = 'errorLoadingCabinet';
  static const String registerToCabinetButton = 'registerToCabinetButton';
  static const String emergencyAlreadyReported = 'emergencyAlreadyReported';
  static const String reportEmergencyTitle = 'reportEmergencyTitle';
  static const String pleaseDescribeSymptoms = 'pleaseDescribeSymptoms';
  static const String enterSymptomsHint = 'enterSymptomsHint';
  static const String reportButton = 'reportButton';
  static const String pleaseEnterSymptoms = 'pleaseEnterSymptoms';
  static const String emergencyReportedSuccess = 'emergencyReportedSuccess';
  static const String nextConsultationLabel = 'nextConsultationLabel';
  static const String registerToCabinetFirstWarning = 'registerToCabinetFirstWarning';
  static const String noConsultationsAvailable = 'noConsultationsAvailable';
  static const String pdfPreviewTitle = 'pdfPreviewTitle';
  static const String closeButton = 'closeButton';
  static const String selectDateRangeReportHelpText = 'selectDateRangeReportHelpText';
  static const String cancelDatePickerButton = 'cancelDatePickerButton';
  static const String noBookingsForPeriod = 'noBookingsForPeriod';
  static const String errorGeneratingPdfGeneric = 'errorGeneratingPdfGeneric';
  static const String doctorDetailsTitle = 'doctorDetailsTitle';
  static const String selectDateAndTimeLabel = 'selectDateAndTimeLabel';
  static const String pleaseSelectDateAndTime = 'pleaseSelectDateAndTime';
  static const String newAppointmentNotificationTitle = 'newAppointmentNotificationTitle';
  static const String newAppointmentNotificationBody = 'newAppointmentNotificationBody';
  static const String failedToLoadDoctorDetails = 'failedToLoadDoctorDetails';
  static const String errorLoadingPage = 'errorLoadingPage';
  static const String navCabinet = 'navCabinet';
  static const String navRequests = 'navRequests';
  static const String navBookings = 'navBookings';
  static const String navChat = 'navChat';
  static const String navProfile = 'navProfile';
  static const String findDoctorPrompt = 'findDoctorPrompt';
  static const String profileTitle = 'profileTitle';
  static const String couldNotOpenCv = 'couldNotOpenCv';
  static const String openCvButton = 'openCvButton';
  static const String editProfileButton = 'editProfileButton';
  static const String emailLabel = 'emailLabel';
  static const String errorDialogTitle = 'errorDialogTitle';
  static const String invalidEmailOrPassword = 'invalidEmailOrPassword';
  static const String userNotFound = 'userNotFound';
  static const String medicalHistoryTitle = 'medicalHistoryTitle';
  static const String noHistoryFound = 'noHistoryFound';
  static const String noMedicalHistoryFound = 'noMedicalHistoryFound';
  static const String failedToFetchBookings = 'failedToFetchBookings';
  static const String failedToFetchMedicalHistory = 'failedToFetchMedicalHistory';
  static const String cabinetTitle = 'cabinetTitle';
  static const String notRegisteredToCabinetPrompt = 'notRegisteredToCabinetPrompt';
  static const String registeredToLabel = 'registeredToLabel';
  static const String cabinetNamePrefixLabel = 'cabinetNamePrefixLabel';
  static const String addressPrefixLabel = 'addressPrefixLabel'; 
  static const String doctorPrefixLabel = 'doctorPrefixLabel'; 
  static const String deregisterFromCabinetButton = 'deregisterFromCabinetButton';
  static const String deregisteredSuccess = 'deregisteredSuccess';
  static const String deregisteredFailed = 'deregisteredFailed';
  static const String parentPrefixLabel = 'parentPrefixLabel'; 
  static const String childrenTitle = 'childrenTitle';
  static const String noChildrenFound = 'noChildrenFound';
  static const String registerChildButton = 'registerChildButton';
  static const String patientDetailsTitle = 'patientDetailsTitle';
  static const String namePrefixLabel = 'namePrefixLabel'; 
  static const String medicalHistoryButton = 'medicalHistoryButton';
  static const String failedToFetchCabinets = 'failedToFetchCabinets';
  static const String navHome = 'navHome';
  static const String navConsultations = 'navConsultations';
  static const String navChildren = 'navChildren';
  static const String userProfileTitle = 'userProfileTitle';
  static const String bookingsSectionTitle = 'bookingsSectionTitle';
  static const String completeEmergencyButton = 'completeEmergencyButton';
  static const String callParentButton = 'callParentButton';
  static const String messageParentButton = 'messageParentButton';
  static const String failedToPickPdf = 'failedToPickPdf';
  static const String failedToUploadImage = 'failedToUploadImage';
  static const String failedToRegisterCabinet = 'failedToRegisterCabinet';
  static const String registerChildTitle = 'registerChildTitle';
  static const String cnpLabel = 'cnpLabel';
  static const String selectDateOfBirthButton = 'selectDateOfBirthButton';
  static const String childMustBeMinorError = 'childMustBeMinorError';
  static const String noDateSelectedError = 'noDateSelectedError';
  static const String childRegisteredSuccess = 'childRegisteredSuccess';
  static const String failedToRegisterChild = 'failedToRegisterChild';
  static const String editProfileTitle = 'editProfileTitle';
  static const String doctorUserType = 'doctorUserType';
  static const String saveChangesButton = 'saveChangesButton';
  static const String userRegisteredSuccessLoginPrompt = 'userRegisteredSuccessLoginPrompt';
  static const String failedToRegisterUser = 'failedToRegisterUser';
  static const String userUpdatedSuccess = 'userUpdatedSuccess';
  static const String failedToUpdateUser = 'failedToUpdateUser';
  static const String failedToUploadCv = 'failedToUploadCv';
  static const String errorLoadingData = 'errorLoadingData';
  static const String errorPatientDataMissing = 'errorPatientDataMissing';
  static const String registrationRequestDetailsTitle = 'registrationRequestDetailsTitle';
  static const String noPatientDetailsAvailable = 'noPatientDetailsAvailable';
  static const String failedToFetchPatientDetails = 'failedToFetchPatientDetails';
  static const String noCabinetDetailsAvailable = 'noCabinetDetailsAvailable';
  static const String failedToFetchCabinetDetails = 'failedToFetchCabinetDetails';
  static const String requestAcceptedSuccess = 'requestAcceptedSuccess';
  static const String failedToAcceptRequest = 'failedToAcceptRequest';
  static const String requestRejectedSuccess = 'requestRejectedSuccess';
  static const String failedToRejectRequest = 'failedToRejectRequest';
  static const String requestStatusLabel = 'requestStatusLabel';
  static const String failedToFetchRegistrationRequests = 'failedToFetchRegistrationRequests';
  static const String couldNotGetConsultations = 'couldNotGetConsultations';
  static const String upcomingMandatoryConsultationsTitle = 'upcomingMandatoryConsultationsTitle';
  static const String errorPrefix = 'errorPrefix'; 
  static const String noUpcomingMandatoryConsultations = 'noUpcomingMandatoryConsultations';
  static const String noChatsFound = 'noChatsFound';
  static const String selectTime = 'selectTime';
  static const String couldNotLoadData = 'couldNotLoadData';
  static const String emergencySymptoms = 'emergencySymptoms';
  static const String couldNotOpenUrl = 'couldNotOpenUrl';
  static const String noCabinetRegisteredYet = 'noCabinetRegisteredYet';
  static const String registerYourCabinet = 'registerYourCabinet';
  static const String invalidBookingData = 'invalidBookingData';
  static const String noPatientsFound = 'noPatientsFound';
  static const String noEmergenciesFound = 'noEmergenciesFound';
  static const String errorLoadingPatient = 'errorLoadingPatient';
  static const String noPatientData = 'noPatientData';
  static const String loading = 'loading';

  // ignore: constant_identifier_names
  static const Map<String, dynamic> EN = {
    title: 'Doctors App',
    welcome: 'Welcome',
    loginToContinue: 'Login to continue',
    login: 'Login',
    password: 'Password',
    rememberMe: 'Remember me',
    emailValidationError: 'Please enter a valid email address',
    passwordValidationError: 'Please enter a valid password',
    registerNewAccount: 'Register new account',
    register: 'Register',
    phoneNumber: 'Phone Number',
    city: 'City',
    firstName: 'First Name',
    lastName: 'Last Name',
    selectDate: 'Select Date',
    birthDate: 'Birth Date',
    selectUserType: 'Select User Type',
    patient: 'Patient',
    selectedDate: 'Selected Date',
    phoneNumberValidationError: 'Please enter a valid phone number',
    firstNameValidationError: 'Please enter a valid first name',
    lastNameValidationError: 'Please enter a valid last name',
    cnpValidationError: 'Please enter your CNP (Personal Numeric Code)',
    cityValidationError: 'Please select a city',
    legitimationNumber: 'Legitimation Number',
    legitimationNumberValidationError: 'Please enter your legitimation number',
    pickCv: 'Pick CV',
    pickCvValidationError: 'Please select a CV file',
    alreadyHaveAnAccount: 'Already have an account? Login',
    numberOfPatients: 'Number of Patients',
    capacity: 'Capacity',
    address: 'Address',
    workingHours: 'Working Hours',
    patientList: 'Patient List',
    emergencies: 'Emergencies',
    editCabinet: 'Edit Cabinet',
    registrationRequests: 'Registration Requests',
    dateOfRequest: 'Date of Request',
    accept: 'Accept',
    reject: 'Reject',
    noRequests: 'No registration requests',
    noPatients: 'No patients found',
    noEmergencies: 'No emergencies found',
    patientName: 'Patient Name',
    patientPhone: 'Patient Phone',
    bookAppointment: 'Book Appointment',
    noAvailableSlots: 'No available slots for the selected date',
    selectedTime: 'Selected Time',
    description: 'Description',
    generateReport: 'Generate Report',
    bookings: 'Bookings',
    noBookings: 'No bookings found',
    acceptingPatients: 'Accepting Patients',
    notAcceptingPatients: 'Not Accepting Patients',
    sendRequestToRegister: 'Send Request to Register',
    call: 'Call',
    message: 'Message',
    viewDoctorProfile: 'View Doctor Profile',
    viewDetails: 'View Details',
    cabinetMap: 'Cabinet Map',
    registerCabinet: 'Register Cabinet',
    cabinetName: 'Cabinet Name',
    cabinetNameValidationError: 'Please enter a valid cabinet name',
    capacityValidationError: 'Please enter a valid capacity',
    openingTime: 'Opening Time',
    closingTime: 'Closing Time',
    openingTimeValidationError: 'Please enter a valid opening time',
    closingTimeValidationError: 'Please enter a valid closing time',
    pickImage: 'Pick Image',
    openMap: 'Open Map',
    chooseLocation: 'Choose Location',
    location: 'Location',
    coordinates: 'Coordinates',
    addMedicalHistoryTitle: 'Add Medical History',
    resultsLabel: 'Results',
    recommendationsLabel: 'Recommendations',
    addAnalysisLabel: 'Add Analysis',
    saveButton: 'Save',
    errorCouldNotSaveMedicalHistory: 'Could not save medical history.',
    selectTimeSlotTitle: 'Select Time Slot',
    okButton: 'OK',
    bookingSuccessful: 'Booking successful!',
    bookingFailed: 'Failed to book appointment.',
    unknownPatient: 'Unknown Patient',
    errorFetchingPatientName: 'Error fetching patient name',
    loadingText: 'Loading...',
    confirmButton: 'Confirm',
    completeButton: 'Complete',
    contactDoctorLabel: 'Contact doctor',
    registrationRequestSentSuccess: 'Registration request sent successfully.',
    registrationRequestFailed: 'Failed to send registration request.',
    couldNotCall: 'Could not make the call.',
    googleMapsTitle: 'Google Maps',
    selectButton: 'Select',
    failedToSelectLocation: 'Failed to select location.',
    chatListTitle: 'Chat List',
    couldNotGetChats: 'Could not get chats.',
    chatWithPrefix: 'Chat with ',
    noMessagesYet: 'No messages yet',
    typeAMessageHint: 'Type a message',
    loadingCabinet: 'Loading cabinet...',
    errorLoadingCabinet: 'Error loading cabinet',
    registerToCabinetButton: 'Register to cabinet',
    emergencyAlreadyReported: 'Emergency already reported.',
    reportEmergencyTitle: 'Report Emergency',
    pleaseDescribeSymptoms: 'Please describe the symptoms:',
    enterSymptomsHint: 'Enter symptoms here',
    reportButton: 'Report',
    pleaseEnterSymptoms: 'Please enter symptoms.',
    emergencyReportedSuccess: 'Emergency reported successfully.',
    nextConsultationLabel: 'Next Consultation:',
    registerToCabinetFirstWarning: 'Register to cabinet first!',
    noConsultationsAvailable: 'No consultations available',
    pdfPreviewTitle: 'PDF Preview',
    closeButton: 'Close',
    selectDateRangeReportHelpText: 'Select Date Range for Report',
    cancelDatePickerButton: 'Cancel',
    noBookingsForPeriod: 'No bookings found for the selected period.',
    errorGeneratingPdfGeneric: 'Error generating PDF.',
    doctorDetailsTitle: 'Doctor Details',
    selectDateAndTimeLabel: 'Select date and time',
    pleaseSelectDateAndTime: 'Please select date and time.',
    newAppointmentNotificationTitle: 'New Appointment',
    newAppointmentNotificationBody: 'New appointment created.',
    failedToLoadDoctorDetails: 'Failed to load doctor details.',
    errorLoadingPage: 'Error loading page.',
    navCabinet: 'Cabinet',
    navRequests: 'Requests',
    navBookings: 'Bookings',
    navChat: 'Chat',
    navProfile: 'Profile',
    findDoctorPrompt: 'Find your doctor, \nand book an appointment',
    profileTitle: 'Profile',
    couldNotOpenCv: 'Could not open CV.',
    openCvButton: 'Open CV',
    editProfileButton: 'Edit Profile',
    emailLabel: 'Email',
    errorDialogTitle: 'Error',
    invalidEmailOrPassword: 'Invalid email or password.',
    userNotFound: 'User not found.',
    medicalHistoryTitle: 'Medical History',
    noHistoryFound: 'No history found.',
    noMedicalHistoryFound: 'No medical history found.',
    failedToFetchBookings: 'Failed to fetch bookings. Please try again later.',
    failedToFetchMedicalHistory: 'Failed to fetch medical history. Please try again later.',
    cabinetTitle: 'Cabinet',
    notRegisteredToCabinetPrompt: 'You haven\'t registered\nto any cabinet yet.',
    registeredToLabel: 'You are registered to:',
    cabinetNamePrefixLabel: 'Cabinet Name: ',
    addressPrefixLabel: 'Address: ',
    doctorPrefixLabel: 'Doctor: ',
    deregisterFromCabinetButton: 'Deregister from Cabinet',
    deregisteredSuccess: 'You have been deregistered from the cabinet.',
    deregisteredFailed: 'Could not deregister from cabinet.',
    parentPrefixLabel: 'Parent : ',
    childrenTitle: 'Children',
    noChildrenFound: 'No children found.',
    registerChildButton: 'Register Child',
    patientDetailsTitle: 'Patient Details',
    namePrefixLabel: 'Name: ',
    medicalHistoryButton: 'Medical History',
    failedToFetchCabinets: 'Failed to fetch cabinets. Please try again later.',
    navHome: 'Home',
    navConsultations: 'Consultations',
    navChildren: 'Children',
    userProfileTitle: 'User Profile',
    bookingsSectionTitle: 'Bookings',
    completeEmergencyButton: 'Complete Emergency',
    callParentButton: 'Call Parent',
    messageParentButton: 'Message Parent',
    failedToPickPdf: 'Failed to pick PDF file.',
    failedToUploadImage: 'Failed to upload image.',
    failedToRegisterCabinet: 'Failed to register cabinet.',
    registerChildTitle: 'Register Child',
    cnpLabel: 'CNP',
    selectDateOfBirthButton: 'Select Date of Birth',
    childMustBeMinorError: 'Child must be a minor (under 18 years old).',
    noDateSelectedError: 'No date selected.',
    childRegisteredSuccess: 'Child registered successfully!',
    failedToRegisterChild: 'Failed to register child.',
    editProfileTitle: 'Edit Profile',
    doctorUserType: 'Doctor',
    saveChangesButton: 'Save Changes',
    userRegisteredSuccessLoginPrompt: 'User registered successfully! Please login.',
    failedToRegisterUser: 'Failed to register user.',
    userUpdatedSuccess: 'User updated successfully!',
    failedToUpdateUser: 'Failed to update user.',
    failedToUploadCv: 'Failed to upload CV.',
    errorLoadingData: 'Error Loading Data',
    errorPatientDataMissing: 'Error: Patient data missing',
    registrationRequestDetailsTitle: 'Registration Request Details',
    noPatientDetailsAvailable: 'No patient details available.',
    failedToFetchPatientDetails: 'Failed to fetch patient details. Please try again later.',
    noCabinetDetailsAvailable: 'No cabinet details available.',
    failedToFetchCabinetDetails: 'Failed to fetch cabinet details. Please try again later.',
    requestAcceptedSuccess: 'Registration request accepted successfully.',
    failedToAcceptRequest: 'Failed to accept registration request. Please try again later.',
    requestRejectedSuccess: 'Registration request rejected successfully.',
    failedToRejectRequest: 'Failed to reject registration request. Please try again later.',
    requestStatusLabel: 'Request Status: ',
    failedToFetchRegistrationRequests: 'Failed to fetch registration requests. Please try again later.',
    couldNotGetConsultations: 'Could not get consultations.',
    upcomingMandatoryConsultationsTitle: 'Upcoming Mandatory Consultations',
    errorPrefix: 'Error: ',
    noUpcomingMandatoryConsultations: 'No upcoming mandatory consultations.',
    noChatsFound: 'No chats found.',
    selectTime: 'Select Time',
    couldNotLoadData: 'Could not load data.',
    emergencySymptoms: 'Emergency Symptoms',
    couldNotOpenUrl: 'Could not open URL.',
    noCabinetRegisteredYet: 'You have not registered your cabinet yet.',
    registerYourCabinet: 'Register cabinet',
    invalidBookingData: 'Invalid booking data',
    noPatientsFound: 'No patients found.',
    noEmergenciesFound: 'No emergencies found.',
    errorLoadingPatient: 'Error loading patient data.',
    noPatientData: 'No patient data available.',
    loading: 'Loading...',
  };

  // ignore: constant_identifier_names
  static const Map<String, dynamic> RO = {
    title: 'Aplicația Doctorilor',
    welcome: 'Bine ați venit',
    loginToContinue: 'Autentificați-vă pentru a continua',
    login: 'Conectează-te',
    password: 'Parolă',
    rememberMe: 'Ține minte contul',
    emailValidationError: 'Vă rugăm să introduceți o adresă de email validă',
    passwordValidationError: 'Vă rugăm să introduceți o parolă validă',
    registerNewAccount: 'Înregistrează un cont nou',
    register: 'Înregistrează-te',
    phoneNumber: 'Număr de telefon',
    city: 'Oraș',
    firstName: 'Prenume',
    lastName: 'Nume de familie',
    selectDate: 'Selectați data',
    birthDate: 'Data nașterii',
    selectUserType: 'Selectați tipul de utilizator',
    patient: 'Pacient',
    selectedDate: 'Data selectată',
    phoneNumberValidationError: 'Vă rugăm să introduceți un număr de telefon valid',
    firstNameValidationError: 'Vă rugăm să introduceți un prenume valid',
    lastNameValidationError: 'Vă rugăm să introduceți un nume de familie valid',
    cnpValidationError: 'Vă rugăm să introduceți un CNP',
    cityValidationError: 'Vă rugăm să selectați un oraș',
    legitimationNumber: 'Număr de legitimație',
    legitimationNumberValidationError: 'Vă rugăm să introduceți un număr de legitimație',
    pickCv: 'Alege CV',
    pickCvValidationError: 'Vă rugăm să selectați un fișier CV',
    alreadyHaveAnAccount: 'Aveți deja un cont? Conectați-vă',
    numberOfPatients: 'Număr de pacienți',
    capacity: 'Capacitate',
    address: 'Adresă',
    workingHours: 'Program de lucru',
    patientList: 'Lista pacienților',
    emergencies: 'Urgențe',
    editCabinet: 'Editează cabinetul',
    registrationRequests: 'Cereri de înregistrare',
    dateOfRequest: 'Data cererii',
    accept: 'Acceptă',
    reject: 'Respinge',
    noRequests: 'Nu există cereri de înregistrare',
    noPatients: 'Nu au fost găsiți pacienți',
    noEmergencies: 'Nu există urgențe',
    patientName: 'Numele pacientului',
    patientPhone: 'Telefonul pacientului',
    bookAppointment: 'Programează o întâlnire',
    noAvailableSlots: 'Nu există intervale disponibile pentru data selectată',
    selectedTime: 'Ora selectată',
    description: 'Descriere',
    generateReport: 'Generează raport',
    bookings: 'Programări',
    noBookings: 'Nu au fost găsite programări',
    acceptingPatients: 'Acceptă pacienți',
    notAcceptingPatients: 'Nu acceptă pacienți',
    sendRequestToRegister: 'Trimite cerere de înregistrare',
    call: 'Sună',
    message: 'Trimiteți mesaj',
    viewDoctorProfile: 'Vezi profilul doctorului',
    viewDetails: 'Vezi detalii',
    cabinetMap: 'Harta cabinetului',
    registerCabinet: 'Înregistrează cabinet',
    cabinetName: 'Numele cabinetului',
    cabinetNameValidationError: 'Vă rugăm să introduceți un nume valid pentru cabinet',
    capacityValidationError: 'Vă rugăm să introduceți o capacitate validă',
    openingTime: 'Ora de deschidere',
    closingTime: 'Ora de închidere',
    openingTimeValidationError: 'Vă rugăm să introduceți o oră de deschidere validă',
    closingTimeValidationError: 'Vă rugăm să introduceți o oră de închidere validă',
    pickImage: 'Alegeți o imagine',
    openMap: 'Deschide harta',
    chooseLocation: 'Alegeți locația',
    location: 'Locație',
    coordinates: 'Coordonate',
    addMedicalHistoryTitle: 'Adaugă Istoric Medical',
    resultsLabel: 'Rezultate',
    recommendationsLabel: 'Recomandări',
    addAnalysisLabel: 'Adaugă Analize',
    saveButton: 'Salvează',
    errorCouldNotSaveMedicalHistory: 'Nu s-a putut salva istoricul medical.',
    selectTimeSlotTitle: 'Selectează Interval Orar',
    okButton: 'OK',
    bookingSuccessful: 'Programare reușită!',
    bookingFailed: 'Programarea a eșuat.',
    unknownPatient: 'Pacient Necunoscut',
    errorFetchingPatientName: 'Eroare la preluarea numelui pacientului',
    loadingText: 'Se încarcă...',
    confirmButton: 'Confirmă',
    completeButton: 'Finalizează',
    contactDoctorLabel: 'Contactează doctorul',
    registrationRequestSentSuccess: 'Cerere de înregistrare trimisă cu succes.',
    registrationRequestFailed: 'Trimiterea cererii de înregistrare a eșuat.',
    couldNotCall: 'Apelul nu a putut fi efectuat.',
    googleMapsTitle: 'Google Maps',
    selectButton: 'Selectează',
    failedToSelectLocation: 'Selectarea locației a eșuat.',
    chatListTitle: 'Listă Chat',
    couldNotGetChats: 'Nu s-au putut prelua chat-urile.',
    chatWithPrefix: 'Chat cu ',
    noMessagesYet: 'Niciun mesaj încă',
    typeAMessageHint: 'Scrie un mesaj',
    loadingCabinet: 'Se încarcă cabinetul...',
    errorLoadingCabinet: 'Eroare la încărcarea cabinetului',
    registerToCabinetButton: 'Înregistrează-te la cabinet',
    emergencyAlreadyReported: 'Urgență deja raportată.',
    reportEmergencyTitle: 'Raportează Urgență',
    pleaseDescribeSymptoms: 'Vă rugăm descrieți simptomele:',
    enterSymptomsHint: 'Introduceți simptomele aici',
    reportButton: 'Raportează',
    pleaseEnterSymptoms: 'Vă rugăm introduceți simptomele.',
    emergencyReportedSuccess: 'Urgență raportată cu succes.',
    nextConsultationLabel: 'Următoarea Consultație:',
    registerToCabinetFirstWarning: 'Înregistrați-vă mai întâi la un cabinet!',
    noConsultationsAvailable: 'Nicio consultație disponibilă',
    pdfPreviewTitle: 'Previzualizare PDF',
    closeButton: 'Închide',
    selectDateRangeReportHelpText: 'Selectați Intervalul de Date pentru Raport',
    cancelDatePickerButton: 'Anulează',
    noBookingsForPeriod: 'Nicio programare găsită pentru perioada selectată.',
    errorGeneratingPdfGeneric: 'Eroare la generarea PDF-ului.',
    doctorDetailsTitle: 'Detalii Doctor',
    selectDateAndTimeLabel: 'Selectați data și ora',
    pleaseSelectDateAndTime: 'Vă rugăm selectați data și ora.',
    newAppointmentNotificationTitle: 'Programare Nouă',
    newAppointmentNotificationBody: 'Programare nouă creată.',
    failedToLoadDoctorDetails: 'Detaliile doctorului nu au putut fi încărcate.',
    errorLoadingPage: 'Eroare la încărcarea paginii.',
    navCabinet: 'Cabinet',
    navRequests: 'Cereri',
    navBookings: 'Programări',
    navChat: 'Chat',
    navProfile: 'Profil',
    findDoctorPrompt: 'Găsește-ți doctorul, \nși programează o întâlnire',
    profileTitle: 'Profil',
    couldNotOpenCv: 'CV-ul nu a putut fi deschis.',
    openCvButton: 'Deschide CV',
    editProfileButton: 'Editează Profilul',
    emailLabel: 'Email',
    errorDialogTitle: 'Eroare',
    invalidEmailOrPassword: 'Email sau parolă invalidă.',
    userNotFound: 'Utilizator negăsit.',
    medicalHistoryTitle: 'Istoric Medical',
    noHistoryFound: 'Niciun istoric găsit.',
    noMedicalHistoryFound: 'Niciun istoric medical găsit.',
    failedToFetchBookings: 'Preluarea programărilor a eșuat. Vă rugăm încercați mai târziu.',
    failedToFetchMedicalHistory: 'Preluarea istoricului medical a eșuat. Vă rugăm încercați mai târziu.',
    cabinetTitle: 'Cabinet',
    notRegisteredToCabinetPrompt: 'Nu sunteți înregistrat\nla niciun cabinet încă.',
    registeredToLabel: 'Sunteți înregistrat la:',
    cabinetNamePrefixLabel: 'Nume Cabinet: ',
    addressPrefixLabel: 'Adresă: ',
    doctorPrefixLabel: 'Doctor: ',
    deregisterFromCabinetButton: 'Dezînregistrează-te de la Cabinet',
    deregisteredSuccess: 'Ați fost dezînregistrat de la cabinet.',
    deregisteredFailed: 'Dezînregistrarea de la cabinet a eșuat.',
    parentPrefixLabel: 'Părinte : ',
    childrenTitle: 'Copii',
    noChildrenFound: 'Niciun copil găsit.',
    registerChildButton: 'Înregistrează Copil',
    patientDetailsTitle: 'Detalii Pacient',
    namePrefixLabel: 'Nume: ',
    medicalHistoryButton: 'Istoric Medical',
    failedToFetchCabinets: 'Preluarea cabinetelor a eșuat. Vă rugăm încercați mai târziu.',
    navHome: 'Acasă',
    navConsultations: 'Consultații',
    navChildren: 'Copii',
    userProfileTitle: 'Profil Utilizator',
    bookingsSectionTitle: 'Programări',
    completeEmergencyButton: 'Finalizează Urgența',
    callParentButton: 'Sună Părintele',
    messageParentButton: 'Mesaj Părintelui',
    failedToPickPdf: 'Selectarea PDF-ului a eșuat.',
    failedToUploadImage: 'Încărcarea imaginii a eșuat.',
    failedToRegisterCabinet: 'Înregistrarea cabinetului a eșuat.',
    registerChildTitle: 'Înregistrează Copil',
    cnpLabel: 'CNP',
    selectDateOfBirthButton: 'Selectați Data Nașterii',
    childMustBeMinorError: 'Copilul trebuie să fie minor (sub 18 ani).',
    noDateSelectedError: 'Nicio dată selectată.',
    childRegisteredSuccess: 'Copil înregistrat cu succes!',
    failedToRegisterChild: 'Înregistrarea copilului a eșuat.',
    editProfileTitle: 'Editează Profilul',
    doctorUserType: 'Doctor',
    saveChangesButton: 'Salvează Modificările',
    userRegisteredSuccessLoginPrompt: 'Utilizator înregistrat cu succes! Vă rugăm să vă conectați.',
    failedToRegisterUser: 'Înregistrarea utilizatorului a eșuat.',
    userUpdatedSuccess: 'Utilizator actualizat cu succes!',
    failedToUpdateUser: 'Actualizarea utilizatorului a eșuat.',
    failedToUploadCv: 'Încărcarea CV-ului a eșuat.',
    errorLoadingData: 'Eroare la Încărcarea Datelor',
    errorPatientDataMissing: 'Eroare: Datele pacientului lipsesc',
    registrationRequestDetailsTitle: 'Detalii Cerere Înregistrare',
    noPatientDetailsAvailable: 'Niciun detaliu despre pacient disponibil.',
    failedToFetchPatientDetails: 'Preluarea detaliilor pacientului a eșuat. Vă rugăm încercați mai târziu.',
    noCabinetDetailsAvailable: 'Niciun detaliu despre cabinet disponibil.',
    failedToFetchCabinetDetails: 'Preluarea detaliilor cabinetului a eșuat. Vă rugăm încercați mai târziu.',
    requestAcceptedSuccess: 'Cerere de înregistrare acceptată cu succes.',
    failedToAcceptRequest: 'Acceptarea cererii de înregistrare a eșuat. Vă rugăm încercați mai târziu.',
    requestRejectedSuccess: 'Cerere de înregistrare respinsă cu succes.',
    failedToRejectRequest: 'Respingerea cererii de înregistrare a eșuat. Vă rugăm încercați mai târziu.',
    requestStatusLabel: 'Status Cerere: ',
    failedToFetchRegistrationRequests: 'Preluarea cererilor de înregistrare a eșuat. Vă rugăm încercați mai târziu.',
    couldNotGetConsultations: 'Consultațiile nu au putut fi preluate.',
    upcomingMandatoryConsultationsTitle: 'Consultații Obligatorii Următoare',
    errorPrefix: 'Eroare: ',
    noUpcomingMandatoryConsultations: 'Nicio consultație obligatorie următoare.',
    noChatsFound: 'Niciun chat găsit.',
    selectTime: 'Alegeți ora',
    couldNotLoadData: 'Nu s-au putut încărca datele.',
    emergencySymptoms: 'Simptomele urgenței',
    couldNotOpenUrl: 'Nu s-a putut deschide URL-ul.',
    noCabinetRegisteredYet: 'Nu ați înregistrat încă cabinetul dvs.',
    registerYourCabinet: 'Înregistrați cabinetul',
    invalidBookingData: 'Datele de rezervare sunt invalide',
    noPatientsFound: 'Nu au fost găsiți pacienți.',
    noEmergenciesFound: 'Nu au fost găsite urgențe.',
    errorLoadingPatient: 'Eroare la încărcarea datelor pacientului.',
    noPatientData: 'Nu există date despre pacient disponibile.',
    loading: 'Se încarcă...',
  };
}