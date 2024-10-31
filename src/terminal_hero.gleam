import ascii_art.{hero}
import gleam/erlang
import gleam/int
import gleam/io.{print, println}
import gleam/string

// import term_size

const intro = "Welcome to this text adventure!
'> ' is the comand line where you enter text.

"

type Level {
  Intro
  GoblinsAttack
  Dragon
  Bailed
  TheEnd
}

type Hero {
  Hero(hp: Int)
}

type Monster {
  Goblins(hp: Int)
  None(hp: Int)
}

type GameState {
  GameState(level: Level, hero: Hero, monster: Monster)
}

type Action {
  Bail
  Explore
  Fight
}

fn initial_game_state() {
  GameState(level: Intro, hero: Hero(hp: 10), monster: None(hp: 1000))
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
  print_hero_stats(game_state.hero)

  let original_level = game_state.level
  let action = read_action()
  let #(repl_state, game_state) = case action {
    Ok(a) -> handle_action(a, game_state)
    Error(msg) -> handle_error(msg, game_state)
  }

  case original_level == game_state.level {
    True -> Nil
    False -> set_the_scene(game_state.level)
  }

  case repl_state {
    Continue -> repl(game_state)
    Stop -> say_good_by()
  }
}

fn set_the_scene(level: Level) {
  case level {
    Intro -> println(ascii_art.splash)
    GoblinsAttack -> {
      println(ascii_art.goblins)
      println("On the way to Dragon Keep you are being ambushed by goblins!")
    }
    Dragon -> {
      println(ascii_art.dragon)
      println("Oh no! There is a dragon threatenting the kingdom!")
    }
    Bailed -> todo
    TheEnd -> todo
  }
}

fn print_hero_stats(hero: Hero) {
  println("HP: " <> int.to_string(hero.hp))
}

fn read_action() -> Result(Action, String) {
  let assert Ok(input) = erlang.get_line("What do you want to do❔ > ")
  let input = input |> string.trim |> string.lowercase

  case input {
    "bail" -> Ok(Bail)
    "exit" -> Ok(Bail)
    "quit" -> Ok(Bail)
    "q" -> Ok(Bail)

    "explore" -> Ok(Explore)
    "ex" -> Ok(Explore)
    "e" -> Ok(Explore)

    "fight" -> Ok(Fight)
    "f" -> Ok(Fight)

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
    Fight -> fight(game_state)
    // #(Continue, game_state)
  }
}

fn explore(game_state: GameState) {
  let next_game_state = case game_state.level {
    Intro -> {
      GameState(..game_state, level: GoblinsAttack, monster: Goblins(hp: 3))
    }
    GoblinsAttack -> {
      GameState(..game_state, level: Dragon, monster: None(hp: 100))
    }
    Dragon -> todo
    Bailed -> todo
    TheEnd -> todo
  }
  #(Continue, next_game_state)
}

type Check {
  Success
  Failure
}

fn fight(game_state: GameState) {
  let next_game_state = case game_state.level {
    Intro -> {
      println("There is no one to fight!")
      game_state
    }
    GoblinsAttack -> {
      let roll = int.random(3) + 1
      // io.debug(roll)
      let roll_result = case roll {
        1 -> Failure
        2 -> Success
        3 -> Success
        _ -> panic
      }

      case roll_result {
        Success -> {
          println("You strike true!")
          let gobline_hp = game_state.monster.hp - 1

          case gobline_hp > 0 {
            True -> {
              println("The Goblins take a serious hit.")
              GameState(..game_state, monster: Goblins(hp: gobline_hp))
            }
            False -> {
              println(
                "The Goblins are clearly outmatched! They flee in terror!",
              )
              GameState(..game_state, level: Dragon, monster: None(hp: 100))
            }
          }
        }
        Failure -> {
          println("The goblins are gaining on you.")
          GameState(..game_state, hero: Hero(hp: game_state.hero.hp - 1))
        }
      }
    }
    Dragon -> todo
    Bailed -> todo
    TheEnd -> todo
  }
  #(Continue, next_game_state)
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

fn d20_result() -> Int {
  int.random(20) + 1
}
