<template>
  <div class="MainBoard">
    <router-link :to="{ name: 'home' }"> ← back</router-link>
    <h1>Space Opera - {{ stage?.name }}</h1>
    <div v-if="stage && board">
      <div class="MainBoard-row" v-for="rowIndex in stage.rows" :key="rowIndex">
        <div
          class="MainBoard-col"
          :class="{
            'MainBoard-col--selected':
              this.piece1?.id === `${rowIndex - 1}-${colIndex - 1}` ||
              this.piece2?.id === `${rowIndex - 1}-${colIndex - 1}`,
          }"
          :style="{
            'flex-basis': `${stage.pieceSize}px`,
            'height': `${stage.pieceSize}px`,
          }"
          v-for="colIndex in stage.cols"
          :key="colIndex"
          :ref="`${rowIndex - 1}-${colIndex - 1}`"
        >
          <component
            class="MainBoard-piece"
            :class="{
              'MainBoard-piece--moveUp':
                this.moveUp.includes(`${rowIndex - 1}-${colIndex - 1}`),
              'MainBoard-piece--moveDown':
                this.moveDown.includes(`${rowIndex - 1}-${colIndex - 1}`),
              'MainBoard-piece--moveLeft':
                this.moveLeft.includes(`${rowIndex - 1}-${colIndex - 1}`),
              'MainBoard-piece--moveRight':
                this.moveRight.includes(`${rowIndex - 1}-${colIndex - 1}`),
            }"
            :style="{
              transition: `all ${switchMoveDuration}ms`,
            }"
            :matchs="board[rowIndex - 1][colIndex - 1]?.matchs"
            :is="`${board[rowIndex - 1][colIndex - 1]?.value}`"
            @click="selectPiece(rowIndex - 1, colIndex - 1)"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import stage_1 from "../stages/stage_1.json";
import stage_2 from "../stages/stage_2.json";
import alien from "../components/pieces/alien.vue";
import astronaut from "../components/pieces/astronaut.vue";
import bomb from "../components/pieces/bomb.vue";
import ghost from "../components/pieces/ghost.vue";
import moon from "../components/pieces/moon.vue";
import pistol from "../components/pieces/pistol.vue";
import rocket from "../components/pieces/rocket.vue";
import saturn from "../components/pieces/saturn.vue";
import star from "../components/pieces/star.vue";

export default {
  name: "MainBoard",
  components: {
    alien,
    astronaut,
    bomb,
    ghost,
    moon,
    pistol,
    rocket,
    saturn,
    star,
  },
  data() {
    return {
      stage: null,
      board: null,
      stages: [stage_1, stage_2],
      piece1: null,
      piece2: null,
      switchMoveDuration: 200,
      moveUp: [],
      moveDown: [],
      moveLeft: [],
      moveRight: [],
    };
  },

  mounted() {
    if (this.$route?.params?.stage) {
      this.stage = this.stages[parseInt(this.$route?.params?.stage, 10) - 1]
      this.board = this.getBoard()
      this.countAllMatchs()
    }
  },

  methods: {
    getPieceObject(rowIndex, colIndex) {
      return {
        row: rowIndex,
        col: colIndex,
        id: `${rowIndex}-${colIndex}`,
        matchs: 0,
        value: this.stage.board[rowIndex][colIndex],
      };
    },
    getBoard() {
      let board = []
      this.stage.board.forEach((row, rowIndex) => {
        let newRow = []
        row.forEach((col, colIndex) => {
          newRow.push(this.getPieceObject(rowIndex, colIndex));
        });
        board.push(newRow)
      });

      return board
    },

    selectPiece(rowIndex, colIndex) {
      const isFirstOne = this.selectPiece1(rowIndex, colIndex)

      if (!isFirstOne) {
        this.selectPiece2(rowIndex, colIndex)
      }
    },

    selectPiece1(rowIndex, colIndex) {
      if (this.piece1 === null) {
        this.piece1 = this.cloneObject(this.board[rowIndex][colIndex])

        return true
      }
      if (this.piece1.row === rowIndex && this.piece1.col === colIndex) {
        this.piece1 = null

        return true
      }

      return false
    },
    selectPiece2(rowIndex, colIndex) {
      const pieceObj = this.cloneObject(this.board[rowIndex][colIndex])
      if (this.piece2?.row === rowIndex && this.piece2?.col === colIndex) {
        this.piece2 = null
        return
      }
      const moveDirection = this.pieceShoudMove(this.piece1, pieceObj);
      if (moveDirection) {
        this.piece2 = pieceObj
        this.movePieces(moveDirection)
      } else {
        this.piece2 = null
        this.piece1 = pieceObj
      }
    },
    pieceShoudMove(piece1, piece2) {
      if (piece1.row === piece2.row - 1 && piece1.col === piece2.col)
        return "down"
      if (piece1.row === piece2.row + 1 && piece1.col === piece2.col)
        return "up"
      if (piece1.col === piece2.col - 1 && piece1.row === piece2.row)
        return "right"
      if (piece1.col === piece2.col + 1 && piece1.row === piece2.row)
        return "left"

      return null
    },
    movePieces(direction) {
      if (direction === "left") {
        this.moveLeft.push(this.piece1.id)
        this.moveRight.push(this.piece2.id)
      }
      if (direction === "right") {
        this.moveRight.push(this.piece1.id)
        this.moveLeft.push(this.piece2.id)
      }
      if (direction === "up") {
        this.moveUp.push(this.piece1.id)
        this.moveDown.push(this.piece2.id)
      }
      if (direction === "down") {
        this.moveDown.push(this.piece1.id)
        this.moveUp.push(this.piece2.id)
      }
      if (this.stage.pieceMoveRule === "free")
        setTimeout(this.switchPlaces, this.switchMoveDuration);
      if (this.stage.pieceMoveRule === "match2") this.moveRuleMatch(2);
    },
    pullColumn (piece) {
      const nextPiece = this.board[piece.row + 1][piece.col]
      if (nextPiece.value === null) {
        this.moveDown.push(piece.id)
        console.log(this.moveDown)

        for(let r = piece.row - 1; r > 0; r--) {
          this.moveDown.push(this.board[r][piece.col].id)
        }
        setTimeout(() => {
          console.log(piece.row, "outside")
          nextPiece.value = piece.value
          piece.value = null

          this.moveDown = this.moveDown.filter(id => (id !== piece.id))
          for(let r = piece.row - 1; r >= -1; r--) {
            if (r === -1) {
              this.board[0][piece.col].value = this.getRandomValue()
            } else {
              this.board[r + 1][piece.col].value = this.board[r][piece.col].value
              this.moveDown = this.moveDown.filter(id => (id !== this.board[r][piece.col].id))
            }
          } 

          if (this.board[nextPiece.row + 1][piece.col].value === null) {
            setTimeout(()=> {
              this.pullColumn(nextPiece)
            }, 1)
          }
        }, this.switchMoveDuration);
      }
    },
    getRandomValue() {
      const row = Math.floor(Math.random() * this.board.length)
      const col = Math.floor(Math.random() * this.board[0].length)
      console.log(row, col)

      return this.board[row][col].value
    },
    removePiecesMatching(amount) {
      let removed = []
      this.board.forEach((row) => {
        row.forEach((piece) => {
          if (piece.matchs >= amount) {
            removed.push(piece)
            this.board[piece.row][piece.col].value = null
          }
        })
      })

      if (removed.length > 0) {
        removed.forEach(piece => {
          if (this.board[piece.row - 1][piece.col].value !== null) {
            this.pullColumn(this.board[piece.row - 1][piece.col])
          }
        })
      }
    },
    switchPlaces() {
      const piece1 = this.board[this.piece1.row][this.piece1.col].value;
      const piece2 = this.board[this.piece2.row][this.piece2.col].value;
      this.rollbackPosition();

      this.board[this.piece1.row][this.piece1.col].value = piece2;
      this.board[this.piece2.row][this.piece2.col].value = piece1;

      this.piece1 = null;
      this.piece2 = null;

      this.countAllMatchs()
    },
    moveRuleMatch(match) {
      let tempBoard = this.cloneObject(this.board)
      const piece1 = {...this.piece2, value: this.piece1.value}
      const piece2 = {...this.piece1, value: this.piece2.value}
      tempBoard[piece1.row][piece1.col] = piece1
      tempBoard[piece2.row][piece2.col] = piece2

      const matchs1 = this.countMatches(
        tempBoard,
        piece1
      )
      const matchs2 = this.countMatches(
        tempBoard,
        piece2
      )

      const haveMatch = matchs1 >= match || matchs2 >= match
      if (haveMatch) {
        setTimeout(this.switchPlaces, this.switchMoveDuration)
        return
      }
      setTimeout(() => {
        this.rollbackPosition()
        this.piece1 = null
        this.piece2 = null
      }, this.switchMoveDuration)
    },

    countMatches(board, piece) {
      let rowMatchs = 1;
      let colMatchs = 1;

      for (let i = piece.col - 1; i >= 0; i--) {
        if (piece.value === board[piece.row][i].value) {
          rowMatchs++;
        } else {
          i = -1;
        }
      }

      for (let i = piece.col + 1; i < board[0].length; i++) {
        if (piece.value === board[piece.row][i].value) {
          rowMatchs++;
        } else {
          i = board[0].length + 1;
        }
      }

      for (let i = piece.row - 1; i >= 0; i--) {
        if (piece.value === board[i][piece.col].value) {
          colMatchs++;
        } else {
          i = -1;
        }
      }
      for (let i = piece.row + 1; i < board[0].length; i++) {
        if (piece.value === board[i][piece.col].value) {
          colMatchs++;
        } else {
          i = board.length + 1;
        }
      }

      return rowMatchs > colMatchs ? rowMatchs : colMatchs;
    },

    countAllMatchs() {
      this.board.forEach((row) => {
        row.forEach((col) => {
          col.matchs = this.countMatches(this.board, col)
        })
      })
      
      if (this.stage.pieceRemovalRule === "match3") {
        setTimeout(() => this.removePiecesMatching(3), this.switchMoveDuration)
      }
    },

    rollbackPosition() {
      this.moveUp = []
      this.moveDown = []
      this.moveLeft = []
      this.moveRight = []
    },
    cloneObject(obj){
      return JSON.parse(JSON.stringify(obj))
    },
  },
};
</script>

<style lang="scss" scoped>
.MainBoard {
  &-row {
    display: flex;
    flex-flow: row nowrap;
    align-items: center;
    justify-content: center;
  }
  &-col {
    position: relative;
    flex: 0 0 50px;
    align-items: center;
    justify-content: center;
    height: 50px;
    outline: 1px solid #f3f3f3;
    cursor: pointer;

    &--selected {
      outline: 2px solid purple;
    }
  }
  &-piece {
    position: absolute;
    top: 0;
    left: 0;

    &--moveUp {
      top: -50px;
      fill: purple;
    }
    &--moveDown {
      top: 50px;
      outline: 1px solid red;
      fill: purple;
    }
    &--moveLeft {
      left: -50px;
      fill: purple;
    }
    &--moveRight {
      left: 50px;
      fill: purple;
    }
  }
}
</style>
