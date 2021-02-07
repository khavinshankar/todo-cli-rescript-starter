/*
Sample JS implementation of Todo CLI that you can attempt to port:
https://gist.github.com/jasim/99c7b54431c64c0502cfe6f677512a87
*/

/* Returns date with the format: 2021-02-04 */
let getToday: unit => string = %raw(`
function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
}
  `)

type fsConfig = {encoding: string, flag: string}

/* https://nodejs.org/api/fs.html#fs_fs_existssync_path */
@bs.module("fs") external existsSync: string => bool = "existsSync"

/* https://nodejs.org/api/fs.html#fs_fs_readfilesync_path_options */
@bs.module("fs")
external readFileSync: (string, fsConfig) => string = "readFileSync"

/* https://nodejs.org/api/fs.html#fs_fs_writefilesync_file_data_options */
@bs.module("fs")
external appendFileSync: (string, string, fsConfig) => unit = "appendFileSync"

@bs.module("fs")
external writeFileSync: (string, string, fsConfig) => unit = "writeFileSync"

/* https://nodejs.org/api/os.html#os_os_eol */
@bs.module("os") external eol: string = "EOL"

let encoding = "utf8"

/*
NOTE: The code below is provided just to show you how to use the
date and file functions defined above. Remove it to begin your implementation.
*/

/* * Constant Values */
@bs.val external __dirname: string = "__dirname"
@bs.val external argv: array<string> = "process.argv"

let todoFile = "todo.txt"
let doneFile = "done.txt"

let helpInfo = `Usage :-
$ ./todo add "todo item"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics`

/* * Helper Functions */
let arrlen = arr => arr->Belt.Array.length
let strlen = str => str->Js.String.length

let strToInt = str => {
  let value = Belt.Int.fromString(str)
  switch value {
  | None => -1
  | Some(x) => x
  }
}

let fileRead = filename => {
  if filename->existsSync {
    let filedata = filename->readFileSync({encoding: encoding, flag: "r"})
    eol->Js.String.split(filedata->Js.String.trim)
  } else {
    []
  }
}

let fileWrite = (filename, todos) => {
  let content = todos->Belt.Array.joinWith(eol, todo => todo)
  filename->writeFileSync(content, {encoding: encoding, flag: "w+"})
}

let fileAppend = (filename, todo) => {
  let content = todo ++ eol
  filename->appendFileSync(content, {encoding: encoding, flag: "a+"})
}

/* * Program Code */
let args = argv->Belt.Array.slice(~offset=2, ~len=argv->arrlen)

let help = () => {
  Js.log(helpInfo)
}

let add = () => {
  if args->arrlen == 1 {
    Js.log("Error: Missing todo string. Nothing added!")
  } else {
    todoFile->fileAppend(args[1])
    Js.log(`Added todo: "${args[1]}"`)
  }
}

let ls = () => {
  let todos = todoFile->fileRead
  if todos->arrlen == 0 {
    Js.log("There are no pending todos!")
  } else {
    todos
    ->Belt.Array.reverse
    ->Belt.Array.forEachWithIndex((i, todo) =>
      Js.log(`[${Belt.Int.toString(todos->arrlen - i)}] ${todo}`)
    )
  }
}

let del = () => {
  if args->arrlen == 1 {
    Js.log("Error: Missing NUMBER for deleting todo.")
  } else {
    let todos = todoFile->fileRead
    let pos = strToInt(args[1])
    let idx = todos->arrlen - pos
    if todos->arrlen <= idx || idx < 0 {
      Js.log(`Error: todo #${Belt.Int.toString(pos)} does not exist. Nothing deleted.`)
    } else {
      let _ = todos->Js.Array.spliceInPlace(~pos=idx, ~remove=1, ~add=[])
      todoFile->fileWrite(todos)
      Js.log(`Deleted todo #${Belt.Int.toString(pos)}`)
    }
  }
}

let don = () => {
  if args->arrlen == 1 {
    Js.log("Error: Missing NUMBER for marking todo as done.")
  } else {
    let todos = todoFile->fileRead
    let pos = strToInt(args[1])
    let idx = todos->arrlen - pos
    if todos->arrlen <= idx || idx < 0 {
      Js.log(`Error: todo #${Belt.Int.toString(pos)} does not exist.`)
    } else {
      let completed = todos->Js.Array.spliceInPlace(~pos=idx, ~remove=1, ~add=[])
      todoFile->fileWrite(todos)
      let completedTodo = `x ${getToday()} ${completed[0]}`
      doneFile->fileAppend(completedTodo)
      Js.log(`Marked todo #${Belt.Int.toString(pos)} as done.`)
    }
  }
}

let rep = () => {
  let active = todoFile->fileRead
  let completed = doneFile->fileRead

  Js.log(
    `${getToday()} Pending : ${Belt.Int.toString(active->arrlen)} Completed : ${Belt.Int.toString(
        completed->arrlen,
      )}`,
  )
}

if args->arrlen == 0 {
  help()
} else {
  switch args[0] {
  | "add" => add()
  | "ls" => ls()
  | "del" => del()
  | "done" => don()
  | "report" => rep()
  | _ => help()
  }
}
