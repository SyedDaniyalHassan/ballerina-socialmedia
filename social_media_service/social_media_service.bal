import ballerina/http;
import ballerina/time;
import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;

type User record {|
    readonly int id;
    string name;
    time:Date birthDate;
    string mobileNumber;

|};

table<User> key(id) userTable = table [
    {
        id: 1,
        name: "daniyal hassan",
        birthDate: {year: 1999, month: 8, day: 11}
        ,
        mobileNumber: "0309-1234567"
    },
    {
        id: 2,
        name: "Alliyan hassan",
        birthDate: {year: 2000, month: 8, day: 26}
        ,
        mobileNumber: "0309-1234567"
    }
];

type ErrorDetails record {
    string message;
    string details;
    time:Utc timeStamp;
};

type UserNotFound record {|
    *http:NotFound;
    ErrorDetails body;
    
|};

type NewUser record {|
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

mysql:Client socialMediaDb =check  new("localhost","social_media_user","dummypassword","social_media_database",3306);

service /social\-media on new http:Listener(9090) {
    resource function get users() returns User[]|error {
        stream<User, sql:Error?> allUsers = socialMediaDb->query(`Select * from users`);
        return from var user in allUsers select user;
    }

    resource function get users/[int id]() returns User| error | UserNotFound {
        User? user = userTable[id];
        if user is ()
        {
            UserNotFound userNotFound = {body: {message: string `Id ${id}`, details: string `user/${id} not found`, timeStamp: time:utcNow()}};
            return userNotFound;
        }
        return user;
    }

    resource function put users(NewUser newUser) returns http:Created | error{
        userTable.add({id: userTable.length()+1, ...newUser});
        return http:CREATED;
        
    }

}
