

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.

// The Firebase Admin SDK to access the Firebase Realtime Database.
'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const iconURL = 'https://firebasestorage.googleapis.com/v0/b/eazyfitness-7ac29.appspot.com/o/eazyfitness.png?alt=media&token=77af2a68-fb0e-483b-8e22-3cb9121d4199'
admin.initializeApp();

/**
 * Triggers when a user gets a new follower and sends a notification.
 *
 * Followers add a flag to `/followers/{followedUid}/{followerUid}`.
 * Users save their device notification tokens to `/users/{followedUid}/notificationTokens/{notificationToken}`.
 */


exports.sendNotification = functions.database.ref('/notification/{receiverUID}/{senderUID}')
    .onWrite((change, context) => {
      const receiverUID = context.params.receiverUID;
      const senderUID = context.params.senderUID;
      
      // If un-follow we exit the function.
      if (!change.after.val()) {
        return console.log('message deleted');
      }

      // Get the list of device notification tokens.
      const getDeviceTokensPromise = admin.database()
          .ref(`/users/${receiverUID}/notificationTokens`).once('value');

      // Get the sender profile.
      const getSenderProfilePromise = admin.auth().getUser(senderUID);

      const getMessageText = admin.database()
          .ref(`/notification/${receiverUID}/${senderUID}/message`).once('value');
      const getTitleText = admin.database()
          .ref(`/notification/${receiverUID}/${senderUID}/title`).once('value');

      // The snapshot to the user's tokens.
      let tokensSnapshot;

      // The array containing all the user's tokens.
      let tokens;

      return Promise.all([getDeviceTokensPromise, getSenderProfilePromise, getMessageText, getTitleText]).then(results => {
        tokensSnapshot = results[0];
        const sender = results[1];
        const messageText = results[2];
        const titleText = results[3];

        console.log(`${messageText.val()}, ${titleText}`);

        // Check if there are any device tokens.
        // Notification details.
        const payload = {
          notification: {
            title: `${sender.displayName} ${titleText.val()}`,
            body: `${messageText.val()}`,
            sound: 'note'
          }
        };

        // Listing all tokens as an array.
        //tokens = Object.keys(tokensSnapshot.val());
        // Send notifications to all tokens.
        return admin.messaging().sendToDevice(tokensSnapshot.val(), payload);

      }).then((response) => {
        // For each message check if there was an error.
        const tokensToRemove = [];
        /*
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {
            console.error('Failure sending notification to', tokens[index], error);
            // Cleanup the tokens who are not registered anymore.
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
              tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
            }
          }
        });
        */

        return Promise.all(tokensToRemove);
      });
    });
