// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Fs = require("fs");
var Os = require("os");
var Curry = require("bs-platform/lib/js/curry.js");
var Belt_Int = require("bs-platform/lib/js/belt_Int.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Caml_array = require("bs-platform/lib/js/caml_array.js");

var getToday = (function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
});

var encoding = "utf8";

var todoFile = "todo.txt";

var doneFile = "done.txt";

var helpInfo = "Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics";

function arrlen(arr) {
  return arr.length;
}

function strlen(str) {
  return str.length;
}

function strToInt(str) {
  var value = Belt_Int.fromString(str);
  if (value !== undefined) {
    return value;
  } else {
    return -1;
  }
}

function fileRead(filename) {
  if (!Fs.existsSync(filename)) {
    return [];
  }
  var filedata = Fs.readFileSync(filename, {
        encoding: encoding,
        flag: "r"
      });
  return filedata.trim().split(Os.EOL);
}

function fileWrite(filename, todos) {
  var content = Belt_Array.joinWith(todos, Os.EOL, (function (todo) {
          return todo;
        }));
  Fs.writeFileSync(filename, content, {
        encoding: encoding,
        flag: "w+"
      });
  
}

function fileAppend(filename, todo) {
  var content = todo + Os.EOL;
  Fs.appendFileSync(filename, content, {
        encoding: encoding,
        flag: "a+"
      });
  
}

var args = Belt_Array.slice(process.argv, 2, process.argv.length);

function help(param) {
  console.log(helpInfo);
  
}

function add(param) {
  if (args.length === 1) {
    console.log("Error: Missing todo string. Nothing added!");
  } else {
    fileAppend(todoFile, Caml_array.get(args, 1));
    console.log("Added todo: \"" + Caml_array.get(args, 1) + "\"");
  }
  
}

function ls(param) {
  var todos = fileRead(todoFile);
  if (todos.length === 0) {
    console.log("There are no pending todos!");
    return ;
  } else {
    return Belt_Array.forEachWithIndex(Belt_Array.reverse(todos), (function (i, todo) {
                  console.log("[" + String(todos.length - i | 0) + "] " + todo);
                  
                }));
  }
}

function del(param) {
  if (args.length === 1) {
    console.log("Error: Missing NUMBER for deleting todo.");
    return ;
  }
  var todos = fileRead(todoFile);
  var pos = strToInt(Caml_array.get(args, 1));
  var idx = todos.length - pos | 0;
  if (todos.length <= idx || idx < 0) {
    console.log("Error: todo #" + String(pos) + " does not exist. Nothing deleted.");
  } else {
    todos.splice(idx, 1);
    fileWrite(todoFile, todos);
    console.log("Deleted todo #" + String(pos));
  }
  
}

function don(param) {
  if (args.length === 1) {
    console.log("Error: Missing NUMBER for marking todo as done.");
    return ;
  }
  var todos = fileRead(todoFile);
  var pos = strToInt(Caml_array.get(args, 1));
  var idx = todos.length - pos | 0;
  if (todos.length <= idx || idx < 0) {
    console.log("Error: todo #" + String(pos) + " does not exist.");
    return ;
  }
  var completed = todos.splice(idx, 1);
  fileWrite(todoFile, todos);
  var completedTodo = "x " + Curry._1(getToday, undefined) + " " + Caml_array.get(completed, 0);
  fileAppend(doneFile, completedTodo);
  console.log("Marked todo #" + String(pos) + " as done.");
  
}

function rep(param) {
  var active = fileRead(todoFile);
  var completed = fileRead(doneFile);
  console.log(Curry._1(getToday, undefined) + " Pending : " + String(active.length) + " Completed : " + String(completed.length));
  
}

if (args.length === 0) {
  console.log(helpInfo);
} else {
  var match = Caml_array.get(args, 0);
  switch (match) {
    case "add" :
        add(undefined);
        break;
    case "del" :
        del(undefined);
        break;
    case "done" :
        don(undefined);
        break;
    case "ls" :
        ls(undefined);
        break;
    case "report" :
        rep(undefined);
        break;
    default:
      console.log(helpInfo);
  }
}

exports.getToday = getToday;
exports.encoding = encoding;
exports.todoFile = todoFile;
exports.doneFile = doneFile;
exports.helpInfo = helpInfo;
exports.arrlen = arrlen;
exports.strlen = strlen;
exports.strToInt = strToInt;
exports.fileRead = fileRead;
exports.fileWrite = fileWrite;
exports.fileAppend = fileAppend;
exports.args = args;
exports.help = help;
exports.add = add;
exports.ls = ls;
exports.del = del;
exports.don = don;
exports.rep = rep;
/* args Not a pure module */
