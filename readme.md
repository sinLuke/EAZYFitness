# Eazy Fitness App

## _Database Structure_

### 1. Member:

- All members have a `region`: `Mississauga`, `Scarborough`, `Waterloo`, `London`
- All members have a `userGroup`: `student`, `trainer`, `admin`
- All members that is not an `admin` have a `memberID`.
- All members that is not an `admin` have a monthly `goal`, who achived that goal will rewarded bonus courses.
- All members that is not an `admin` have a `status`: `avaliable`, `canceled`, `unsigned`, `signed`

#### Student:

- A student has only one trainer.
- A student has height and weight been recorded with timestamp.
- Monthly goal for a student is the course hours finished (not settlemented) this month.
- A student has `registedCourse` record the course hours been purchase. This student cannot approving new courses when `registedCourse` minus "Settlement" less than `1` hour. All the value added been recorded with a timestamp.

#### Trainer:

- A student has a list of stuednt.
- Monthly goal for a trainer is the sum of course hours finished (not settlemented) this month.

#### Admin

- Admin can managed and view all the student and trainer that has the same `region` as his/her. The admin has a region `all` can managed and view trainer and student from all regions, this administrator also known as "super".

### 2. User:

- All users contain "name" (`frstName`, `lastName`), `email` and `memberID` that been binded.
- User has one login device UUID stored. If been login in multiple device, the earier one will be forced log out.

### 3. Course:

- Course have `time` (start time) and `amount` (duration). The integer amount value been recorded as half hours (a 2.5 hour course is recorded as `5`)
- A course have one trainer.
- Course have a list of trainee (`student`), each one of them is a `studentCourse` object.

### 4. Student-Course:

- Courses for student have `status`:

| `status`         | Description                                                                                                                  |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `deleted`        | Course been deleted by admin, trainer or student                                                                             |
| `decline`        | Course added by admin and decline by trainer or,<br> added or approved (from admin), by trainer and then declined by student |
| `waitForTrainer` | Course added by admin, or course rescheduled by student                                                                      |
| `waitForStudent` | Course added by admin and appoved by trainer, or course added or rescheduled by trainer                                      |
| `approved`       | Course been approved by trainer or student (added or rescheduled)                                                            |
| `scaned`         | QRCode been scaned during the course time                                                                                    |
| `ill`            | Marked as ill by tariner                                                                                                     |
| `noStudent`      | Marked absent by tariner more than one time in a named month                                                                 |
| `noTrainer`      | Trainer reported absent by student                                                                                           |
| `noCard`         | Marked as no card by tariner more than one time in a named month                                                             |
| `other`          | Marked as other by tariner, explaining `note` must be provided                                                               |
| `noCardFirst`    | Marked as no card by tariner first time in a named month                                                                     |
| `noStudentFirst` | Marked absent by tariner first time in a named month                                                                         |

- Courses for student have `note`. _Like the reson been declined or any other string typed by students or trainers._

### 5. Request:

- Requests for student have `type`:

| `type`                 | Description                                                                                                |
| ---------------------- | ---------------------------------------------------------------------------------------------------------- |
| `studentApproveCourse` | Notify student user to approve course that is `waitForStudent`, feedback also been send.                   |
| `trainerApproveCourse` | Notify trainer user to approve course that is `waitForTrainer`, feedback also been send.                   |
| `studentRemove`        | non-super admin removing a student (or change the status into `canceled`) need to approved by super admin. |
| `trainerRemove`        | non-super admin removing a trainer (or change the status into `canceled`) need to approved by super admin. |
| `studentAddValue`      | non-super admin adding value to a student `registedCourse` need to approved by super admin.                |
| `notification`         | General notifcation hits user's phone                                                                      |
| `other`                | Other situations.                                                                                          |

- Requests for also have `message`, `time`, `senderID`, `reciverID` and "reference" for that event (the course, studentCourse or registedCourse objects):

## _Mobile App_

### 1. Login and Register Page:

#### Login

- Exist user login App by email.

#### Register

- Scan QRCode to get memberID (for a `Student` or a `Trainer`)
- Form for name, email address and password

#### Backend

- (Currently using Firebase) only allow Gmail.
- Only Students and Trainer with an `.unsigned` `userStatus` is allowed to registered with email and password, with a `.signed` `userStatus` is allowed to login.

### 2. Welcome Page

- Show a dedicated webpage
- Simple web page control

### 3. Student Home Page

#### Infomation

- Show next course, current course (if some schedule course is happening) Blocks.
- Show New course Notify menu, student can approve or decline that course (added from trainer).
- Students can reschedule the course.
- Students can report trainer absent during the course time and not been `scaned`.
- Students can view all the curse that finished. (The table shows the multiplier, the total finish time is the course time \* the multiplier)
- Students cannot view the course time been settlemented (The table shows the multiplier), only the admin can view it.

| `status`         | Next course        | Current course     | New course Notify | Reschedule       | Finished | Settlement |
| ---------------- | ------------------ | ------------------ | ----------------- | ---------------- | -------- | ---------- |
| `deleted`        | notify<sup>1</sup> | notify<sup>1</sup> | hide              | hide             | `0`      | `0`        |
| `decline`        | hide               | hide<sup>3</sup>   | hide              | hide             | `0`      | `0`        |
| `waitForTrainer` | hide               | hide               | hide              | hide             | `0`      | `0`        |
| `waitForStudent` | hide               | hide               | menu<sup>4</sup>  | hide             | `0`      | `0`        |
| `approved`       | show               | show               | hide              | show<sup>5</sup> | `0`      | `1`        |
| `scaned`         | hide<sup>2</sup>   | show               | hide              | hide             | `1`      | `1`        |
| `ill`            | hide<sup>2</sup>   | show               | hide              | hide             | `0`      | `1`        |
| `noStudent`      | hide<sup>2</sup>   | show               | hide              | hide             | `0`      | `1`        |
| `noTrainer`      | hide<sup>2</sup>   | show               | hide              | hide             | `0`      | `0`        |
| `noCard`         | hide<sup>2</sup>   | show               | hide              | hide             | `0`      | `1`        |
| `other`          | hide<sup>2</sup>   | show               | hide              | hide             | `0`      | `0`        |
| `noCardFirst`    | hide<sup>2</sup>   | show               | hide              | hide             | `0`      | `0`        |
| `noStudentFirst` | hide<sup>2</sup>   | show               | hide              | hide             | `0`      | `0`        |

<sup>1</sup> Notify will disappear after user dismiss it.<br/>
<sup>2</sup> Future courses cannot be marked as scaned, ill, etc. (This status is impossible)<br/>
<sup>3</sup> Course cannot be declined within 24 hours of the start of the course. (This status is impossible)<br/>
<sup>4</sup> Provide option for approved or decline.<br/>
<sup>5</sup> Course that been approved cannot be rescheduled within 24 hours of, or after, the start of the course.<br/>

#### Time Table

- Show all the course and its status in current week.

### 3. Trainer Home Page

- Show next course, current course (if some schedule course is happening) Blocks.
- Show New course Notify menu, trainer can approve or decline that course (added from admin).
- Trainers can report stdent been absent or illness, didn't bring his/her card, ect. during the course time and not been `scaned`.
- Trainers can view all the curse that finished. (The table shows the multiplier, the total finish time is the course time \* the multiplier)
- Trainers cannot view the course time been settlemented (The table shows the multiplier), only the admin can view it.
- If the course involves more than one (`2` and `3`, more than 3 is not supported) trainees (students), the multiplier will be adjusted (The value will be discused in the furture)

| `status`         | Next course        | Current course     | New course Notify | Reschedule       | Finished<br>`n` trainees | Settlement<br> `n` trainees |
| ---------------- | ------------------ | ------------------ | ----------------- | ---------------- | ------------------------ | --------------------------- |
| `deleted`        | notify<sup>1</sup> | notify<sup>1</sup> | hide              | hide             | `0`                      | `0`                         |
| `decline`        | hide               | hide<sup>3</sup>   | hide              | hide             | `0`                      | `0`                         |
| `waitForTrainer` | hide               | hide               | menu<sup>4</sup>  | hide             | `0`                      | `0`                         |
| `waitForStudent` | show               | hide               | hide              | show             | `0`                      | `0`                         |
| `approved`       | show               | show               | hide              | show<sup>5</sup> | `0`                      | `0`                         |
| `scaned`         | hide<sup>2</sup>   | hide               | hide              | hide             | `1/n`                    | `1/n`                       |
| `ill`            | hide<sup>2</sup>   | hide               | hide              | hide             | `0`                      | `1/2n`                      |
| `noStudent`      | hide<sup>2</sup>   | hide               | hide              | hide             | `0`                      | `1/2n`                      |
| `noTrainer`      | hide<sup>2</sup>   | hide               | hide              | hide             | `0`                      | `0`                         |
| `noCard`         | hide<sup>2</sup>   | hide               | hide              | hide             | `0`                      | `1/2n`                      |
| `other`          | hide<sup>2</sup>   | hide               | hide              | hide             | `0`                      | `1/2n`                      |
| `noCardFirst`    | hide<sup>2</sup>   | hide               | hide              | hide             | `1`                      | `1/n`                       |
| `noStudentFirst` | hide<sup>2</sup>   | hide               | hide              | hide             | `0`                      | `1/2n`                      |

<sup>1</sup> Notify will disappear after user dismiss it.<br/>
<sup>2</sup> Future courses cannot be marked as scaned, ill, etc. (This status is impossible)<br/>
<sup>3</sup> Course cannot be declined within 24 hours of the start of the course. (This status is impossible)<br/>
<sup>4</sup> Provide option for approved or decline.<br/>
<sup>5</sup> Course that been approved cannot be rescheduled within 24 hours of, or after, the start of the course.<br/>

#### Time Table

- Add new courses to one or up tp `3` of his students. Set the start time, amount, and note.
- Show all the courses and its status in current week. Colored by students.

### 4. Admin Home Page

#### Management Page

- Add and edit `student`s and `trainer`s infomations like `firstName`, `lastName`, `memberID` and `status`. (for the `region`)
- View and edit all the `course`s, `studentCourse`s for all `student`s and `trainer`s (for the `region`). Including editing `course` `status` and `time`, `amount` manually without notifications.
- Add and view student's `registedCourse` (non-"super" admin needs "super" admin's approve) after purchasing

#### Infomation Page

- contains all the overview statistical data for the same `region` (all region for "super"), _like the sum of courses hours been finished and settlemented_
- contains all the statistical data for students and trainers for the same `region` (all region for "super") _like the sum of courses hours been finished and settlemented for a single student and trainer (all his/her students), the sum of absents and exceptions been recorded_
- contains the statistical data for settlemented course hours for students and trainers.
