import ascii_art.{hero}
import gleam/erlang
import gleam/io.{print, println}
import gleam/string

// import term_size

const intro = "Welcome to this text adventure!
'> ' is the comand line where you enter text.

"

type Level {
  Intro
  FirstFight
  Bailed
  TheEnd
}

type GameState {
  GameState(level: Level)
}

type Action {
  Bail
  Explore
}

fn initial_game_state() {
  GameState(level: Intro)
}

fn next_level(current_level: Level) {
  case current_level {
    Intro -> FirstFight
    FirstFight -> TheEnd
    TheEnd -> TheEnd
    Bailed -> Bailed
  }
}

pub fn main() {
  io.println(intro)
  print_available_actions()
  println(ascii_art.splash)

  let game_state = initial_game_state()

  repl(game_state)
}

type ReplState {
  Continue
  Stop
}

fn repl(game_state: GameState) {
  let action = read_action()
  let #(repl_state, game_state) = case action {
    Ok(a) -> handle_action(a, game_state)
    Error(msg) -> handle_error(msg, game_state)
  }

  case repl_state {
    Continue -> repl(game_state)
    Stop -> say_good_by()
  }
}

fn read_action() -> Result(Action, String) {
  let assert Ok(input) = erlang.get_line("What do you want to do❔ > ")
  let input = input |> string.trim |> string.lowercase

  case input {
    "bail" -> Ok(Bail)
    "exit" -> Ok(Bail)
    "quit" -> Ok(Bail)
    "explore" -> Ok(Explore)
    _ -> Error(input)
  }
}

fn say_good_by() {
  println("Goodbye!")
}

fn handle_action(a: Action, game_state: GameState) -> #(ReplState, GameState) {
  case a {
    Bail -> #(Stop, game_state)
    Explore -> explore(game_state)
    // #(Continue, game_state)
  }
}

fn explore(game_state: GameState) {
  let next_level = case game_state.level {
    Intro -> {
      println(ascii_art.dragon)
      println("Oh no! There is a dragon threatenting the kingdom!")
      FirstFight
    }
    FirstFight -> todo
    Bailed -> todo
    TheEnd -> todo
  }
  #(Continue, GameState(level: next_level))
}

fn handle_error(msg: String, game_state: GameState) -> #(ReplState, GameState) {
  println("Sorry I don't know what you mean by '" <> msg <> "'")
  print_available_actions()
  #(Continue, game_state)
}

fn print_available_actions() {
  println(
    "Available actions
-----------------
bail
explore
",
  )
}
