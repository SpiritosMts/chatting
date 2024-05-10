


import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebaseVoids.dart';
import 'myVoids.dart';



bool access = false;
bool facebook_login_access = false;
bool google_login_access = false;
bool autoVerifyEmails =false;
bool checkIsLoggedIn =false;
bool shouldNotVerifyRequestInputs =false;

Future<void> getPrivateData()async{
  if(await checkIfDocExists('prData','privateData') == false){
    var value = await addDocument(
      specificID: 'privateData',
      fieldsMap: {
        'access':true,
        'facebook_login_access':false,
        'google_login_access':true,
        'autoVerifyEmails':false,
        'checkIsLoggedIn':false,
        'shouldNotVerifyRequestInputs':false,
      },
      addIDField: false,
      coll: prDataColl,

    );
  }
  print('## getting PD(private Data) ...');
  List<DocumentSnapshot> privateData = await getDocumentsByColl(prDataColl);
  DocumentSnapshot privateDataDoc = privateData[0];// get first doc called 'private data'

  //all fields +
  access = privateDataDoc.get('access');
  facebook_login_access = privateDataDoc.get('facebook_login_access');
  google_login_access = privateDataDoc.get('google_login_access');
  autoVerifyEmails = privateDataDoc.get('autoVerifyEmails');
  checkIsLoggedIn = privateDataDoc.get('checkIsLoggedIn');
  shouldNotVerifyRequestInputs = privateDataDoc.get('shouldNotVerifyRequestInputs');



}