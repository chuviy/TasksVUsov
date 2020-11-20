import UIKit

"""
Задание 1

1) Измените сабскрипт таким образом, чтобы он корректно обрабатывал удаление фигуры с шахматной доски. Не забывайте, что у класса Chessman есть метод kill(). То есть должно происходить не просто удаление фигуры с поля, но и изменение свойства coordinates на nil у самой фигуры.

2) Реализуйте метод printDesk() в классе gameDesk, выполняющий вывод на консоль изображения шахматной доски с помощью символов в следующем виде:
// 1 _ _ _ _ _ _ _ _
// 2 _ _ _ _ _ _ _ _
// 3 _ _ _ _ _ _ _ _
// 4 _ _ _ _ _ _ _ _
// 5 _ _ _ _ _ _ _ _
// 6 _ _ _ _ _ _ _ _
// 7 _ _ _ _ _ _ _ _
// 8 _ _ _ _ _ _ _ _
//   A B C D E F G H
При этом там, где располагаются созданные фигуры должны выводиться их графически отображения (значение свойства symbol класса Chessman).

3) Доработайте классы таким образом, чтобы убитые фигуры (убранные с поля, значение координат изменено на nil) при использовании метода printDesk() появлялись над и под шахматной доской (над шахматной – черные фигуры), под шахматной – белые).


4) Доработайте классы таким образом, чтобы появилась возможность изменить координаты фигуры на поле.
Например:
game.move(from:to:)

5) Если вы чувствуете в себе силы, то реализуйте следующий функционал:
– при попытке передвижения фигуры должна производиться проверка возможности ее перемещения. Попытайтесь реализовать хотя бы для одного типа фигур (к примеру пешка). При этом должны учитываться: особенности первого хода, будет ли съедена в результате хода фигура противника и т.д.

Пример вывода:

♝♜
1 _ _ _ _ _ _ _ _
2 _ _ _ ♚ _ _ _ _
3 _ _ _ _ _ ♛ _ _
4 _ _ _ _ _ _ _ _
5 _ _ _ _ _ _ _ _
6 _ _ _ _ _ _ _ _
7 _ _ _ ♔ _ _ _ _
8 _ _ _ _ _ _ _ _
A B C D E F G H
♙♘♕♖♗

"""

class Chessman {
    enum ChessmanType {
        case king, castle, bishop, pawn, knight, queen
    }
    enum ChessmanColor {
        case black, white
    }
    let type: ChessmanType
    let color: ChessmanColor
    var coordinates: (String, Int)? = nil
    let figureSymbol: Character
    
    func setCoordinates(char c:String, num n: Int) {
        self.coordinates = (c, n)
    }
    func kill() {
        // print("Фигура \(self.type) уничтожена")
        if self.color == .white {
            GameDesk.delChessWhite.append(self)
        } else {
            if self.color == .black {
                GameDesk.delChessBlack.append(self)
            }
        }
        self.coordinates = ("",0)
    }
    
    init(type: ChessmanType, color: ChessmanColor, figure: Character) {
        self.type = type
        self.color = color
        self.figureSymbol = figure
    }
    
    init(type: ChessmanType, color: ChessmanColor, figure: Character, coordinates: (String, Int)) {
        self.type = type
        self.color = color
        self.figureSymbol = figure
        self.setCoordinates(char: coordinates.0, num: coordinates.1)
    }
}

class GameDesk {
    var desk: [Int:[String:Chessman]] = [:]
    static var delChessWhite:[Chessman] = []
    static var delChessBlack:[Chessman] = []
    
    init() {
        for i in 1...8 {
            desk[i] = [:]
        }
    }
    
    func setChessman(chess: Chessman, coordinates: (String, Int)) {
        let rowRange = 1...8
        let colRange = "A"..."H"
        if (rowRange.contains(coordinates.1) && colRange.contains(coordinates.0)) {
            self.desk[coordinates.1]![coordinates.0] = chess // в координаты клетки доски записывается ссылка на фигуру
            chess.setCoordinates(char: coordinates.0, num: coordinates.1) // устанавливаются новые координаты фигуры
        } else {
            print("Coordinates out of range")
        }
        
    }
    
    subscript(alpha: String, number: Int) -> Chessman? {
        get {
            return self.desk[number]![alpha]!
        }
        set {
            if let chessman = newValue {
                self.setChessman(chess: chessman, coordinates: (alpha, number))
                // print("Фигура \(chessman.type) с координатами: \(chessman.coordinates!) установлена на доску \n")
            } else {
                if let chess = self.desk[number]![alpha] {
                    chess.kill() // уничтожаем фигуру через subscript
                }
                self.desk[number]![alpha] = nil // убираем координаты уничтоженной фигуры с доски
            }
        }
    }
    
    func printDelWhite()  {
        if GameDesk.delChessWhite.count != 0 {
            var str = ""
            GameDesk.delChessWhite.forEach { (chessman) in str += String(chessman.figureSymbol) }
            print(str)
        }
    }
    
    func printDelBlack()  {
        if GameDesk.delChessBlack.count != 0 {
            var str = ""
            GameDesk.delChessBlack.forEach { (chessman) in str += String(chessman.figureSymbol) }
            print(str)
        }
    }
    
    func printDesk() {
        var cheesOnDesk: [Chessman] = []
        let dictDesk = ["A":2, "B":4, "C":6, "D":8, "E":10, "F":12, "G":14, "H":16]
        var stringRow: String = "- - - - - - - -"
        var figureSymbol: Character = " "
        func parseDesk() {  // парсим доску
            let rowRange = 1...8
            let colRange = "A"..."H"
            for (_, gorizontDict) in self.desk {
                for (_, chessman) in gorizontDict {
                    if (rowRange.contains(chessman.coordinates!.1) && colRange.contains(chessman.coordinates!.0)) {
                        cheesOnDesk.append(chessman) // сохраняем найденную фигуруна доске
                    }
                }
            }
        }
        parseDesk()
        printDelBlack()
        
        for firstChar in 1...8 {
            stringRow = "\(firstChar) - - - - - - - -"
            
            if cheesOnDesk.count != 0 { // если на доске обнаружены фигуры, то печатаем их
                for chessIndex in cheesOnDesk { // перебор массива с фигурами
                    if chessIndex.coordinates!.1 == firstChar {
                        figureSymbol = chessIndex.figureSymbol
                        for (key,_) in dictDesk {
                            if key == chessIndex.coordinates?.0 {
                                
                                let startIndex = stringRow.startIndex
                                let valueKey = Array(dictDesk.filter{$0.key == chessIndex.coordinates!.0}.values)
                                let by = valueKey[0]
                                let indexChar = stringRow.index(startIndex, offsetBy: by)
                                stringRow.insert(contentsOf: "\(figureSymbol) ", at: indexChar)
                                stringRow.removeLast()
                                continue
                            } else { continue }
                            
                        }
                        continue
                    }
                }
            }
            print(stringRow)
        }
        print("  A B C D E F G H")
        printDelWhite()
    }
    
    func calcPosition(chess: Chessman) ->  String { // position2 - координата куда хочет пойти фигура
        var beforePosition = ""
        var afterPosition = ""
        // var position = ""
        let colArray = ["A","B","C","D","E","F","G","H"]
        
        for i in 0...7 { // инициализируем координаты по горизонтали для возможной рубки
            if colArray[i] == chess.coordinates!.0 {
                beforePosition = colArray[colArray.index(before: i)]
                afterPosition = colArray[colArray.index(after: i)]
            }
        }
        
        if self.desk[chess.coordinates!.1 - 1]![afterPosition] != nil { // если на доске есть фигура то
            self.desk[chess.coordinates!.1 - 1]![afterPosition]!.kill() // удаляем с доски - рубим
            return afterPosition }
        else {
            
            if self.desk[chess.coordinates!.1 - 1]![beforePosition] != nil {
                self.desk[chess.coordinates!.1 - 1]![beforePosition]?.kill()
                return beforePosition }
            
        }
        return (chess.coordinates!.0)
    }
    
    
    
    func move(from chess :Chessman, to coordinates: (String,Int)) {
        if chess.color == .white { // Условие на проверку права первого хода
            
            if chess.type == .pawn {
                
                if chess.coordinates!.1 == 7 { // если белая пешка на 7-й(2-й) горизонтали
                    switch coordinates {
                        case (chess.coordinates!.0, chess.coordinates!.1 - 1):
                            print("Пешка пошла")
                            chess.setCoordinates(char: coordinates.0, num: coordinates.1)
                        case (chess.coordinates!.0, chess.coordinates!.1 - 2):
                            chess.setCoordinates(char: coordinates.0, num: coordinates.1)
                        default:
                            print("Запрещенный ход фигуры")
                    }
                    
                } else { // если белая пешка не на началной горизонтали
                    switch coordinates {
                        case (chess.coordinates!.0, chess.coordinates!.1 - 1):
                            print("Пешка пошла")
                            chess.setCoordinates(char: coordinates.0, num: coordinates.1)
                        
                        case (calcPosition(chess: chess), chess.coordinates!.1 - 1):
                            print("Пешка рубит")
                            chess.setCoordinates(char: coordinates.0, num: coordinates.1)
                        
                        
                        default:
                            print("Запрещенный ход фигуры")
                    }
                }
            } else {chess.setCoordinates(char: coordinates.0, num: coordinates.1)} // если это не пешка то заставляем фигуру сделать ход без анализа
            
        } else { print("Право первого хода у белых фигур.")  }
    }
    
} // end class


var game = GameDesk() // инициализация доски
var queenWhite = Chessman(type: .queen, color: .white, figure: "\u{2655}", coordinates: ("C", 5)) // инициализация фигуры с координатами
var kingWhite = Chessman(type: .king, color: .white, figure: "\u{2654}", coordinates: ("C", 6))
var knightWhite = Chessman(type: .knight, color: .white, figure: "\u{2658}")
var queenBlack = Chessman(type: .queen, color: .black, figure: "\u{265B}")
var knightBlack = Chessman(type: .knight, color: .black, figure: "\u{265E}")
//var pawnWhite1 = Chessman(type: .pawn, color: .white, figure: "\u{2659}")
//var pawnBlack1 = Chessman(type: .pawn, color: .black, figure: "\u{265F}")
var pawnWhite2 = Chessman(type: .pawn, color: .white, figure: "\u{2659}")
var pawnBlack2 = Chessman(type: .pawn, color: .black, figure: "\u{265F}")

game["C",5] = queenWhite // установка фигуры на доску
game["G",4] = queenBlack
game["F",5] = knightBlack
game["A",6] = kingWhite
//game["A",1] = knightWhite
//game["A",2] = pawnWhite1
//game["A",7] = pawnBlack1

game["C",5] = nil // убираю фигуру с шахмотной доски
game["A",6] = nil
game["G",4] = nil
game["F",5] = nil

game["E",5] = pawnWhite2
game["F",4] = pawnBlack2

//game.printDesk()
//game.move(from: knightWhite, to: ("F", 4))

//game.move(from: pawnWhite2, to: ("E",5))
//pawnWhite2.coordinates
//game.printDesk()

game.move(from: pawnWhite2, to: ("F",4))
pawnWhite2.coordinates
game.printDesk()


