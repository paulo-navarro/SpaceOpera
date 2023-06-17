<template>
  <div class="MainBoard">
    <router-link :to="{ name: 'home' }"> ← back</router-link>
    <h1>Space Opera - {{ stage?.name }}</h1>
    <div v-if="stage">
      <div class="MainBoard-row" v-for="rowIndex in stage.rows" :key="rowIndex">
        <div
          class="MainBoard-col"
          :class="{
            'MainBoard-col--selected':
              this.piece1?.id === `${rowIndex - 1}-${colIndex - 1}` ||
              this.piece2?.id === `${rowIndex - 1}-${colIndex - 1}`,
          }"
          v-for="colIndex in stage.cols"
          :key="colIndex"
          :ref="`${rowIndex - 1}-${colIndex - 1}`"
        >
          <component
            class="MainBoard-piece"
            :class="{
              'MainBoard-piece--moveUp':
                this.moveUp === `${rowIndex - 1}-${colIndex - 1}`,
              'MainBoard-piece--moveDown':
                this.moveDown === `${rowIndex - 1}-${colIndex - 1}`,
              'MainBoard-piece--moveLeft':
                this.moveLeft === `${rowIndex - 1}-${colIndex - 1}`,
              'MainBoard-piece--moveRight':
                this.moveRight === `${rowIndex - 1}-${colIndex - 1}`,
            }"
            :style="{
              transition: `all ${switchMoveDuration}ms`,
            }"
            :is="`${stage.board[rowIndex - 1][colIndex - 1]}`"
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
      moveUp: null,
      moveDown: null,
      moveLeft: null,
      moveRight: null,
    };
  },

  mounted() {
    if (this.$route?.params?.stage) {
      this.stage = this.stages[parseInt(this.$route?.params?.stage, 10) - 1];
      this.board = this.getBoard();
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
      let board = [];
      this.stage.board.forEach((row, rowIndex) => {
        let newRow = [];
        row.forEach((col, colIndex) => {
          newRow.push(this.getPieceObject(rowIndex, colIndex));
        });
        board.push(newRow);
      });
      console.log(this.board, this.stage.board);
      return board;
    },
    selectPiece(rowIndex, colIndex) {
      const isFirstOne = this.selectPiece1(rowIndex, colIndex);

      if (!isFirstOne) {
        this.selectPiece2(rowIndex, colIndex);
      }
    },
    selectPiece1(rowIndex, colIndex) {
      if (this.piece1 === null) {
        this.piece1 = this.getPieceObject(rowIndex, colIndex);

        return true;
      }
      if (this.piece1.row === rowIndex && this.piece1.col === colIndex) {
        this.piece1 = null;

        return true;
      }

      return false;
    },
    selectPiece2(rowIndex, colIndex) {
      const pieceObj = this.getPieceObject(rowIndex, colIndex);
      if (this.piece2?.row === rowIndex && this.piece2?.col === colIndex) {
        this.piece2 = null;
        return;
      }
      const moveDirection = this.pieceShoudMove(this.piece1, pieceObj);
      if (moveDirection) {
        this.piece2 = pieceObj;
        this.movePieces(moveDirection);
      } else {
        this.piece2 = null;
        this.piece1 = pieceObj;
      }
    },
    pieceShoudMove(piece1, piece2) {
      if (piece1.row === piece2.row - 1 && piece1.col === piece2.col)
        return "down";
      if (piece1.row === piece2.row + 1 && piece1.col === piece2.col)
        return "up";
      if (piece1.col === piece2.col - 1 && piece1.row === piece2.row)
        return "right";
      if (piece1.col === piece2.col + 1 && piece1.row === piece2.row)
        return "left";

      return null;
    },
    movePieces(direction) {
      if (direction === "left") {
        this.moveLeft = this.piece1.id;
        this.moveRight = this.piece2.id;
      }
      if (direction === "right") {
        this.moveRight = this.piece1.id;
        this.moveLeft = this.piece2.id;
      }
      if (direction === "up") {
        this.moveUp = this.piece1.id;
        this.moveDown = this.piece2.id;
      }
      if (direction === "down") {
        this.moveDown = this.piece1.id;
        this.moveUp = this.piece2.id;
      }
      if (this.stage.pieceMoveRule === "free")
        setTimeout(this.switchPlaces, this.switchMoveDuration);
      if (this.stage.pieceMoveRule === "match2") this.moveRuleMatch(2);
    },
    switchPlaces() {
      const piece1 = this.stage.board[this.piece1.row][this.piece1.col];
      const piece2 = this.stage.board[this.piece2.row][this.piece2.col];
      this.rollbackPosition();

      this.stage.board[this.piece1.row][this.piece1.col] = piece2;
      this.stage.board[this.piece2.row][this.piece2.col] = piece1;

      this.piece1 = null;
      this.piece2 = null;
    },
    moveRuleMatch(match) {
      let tempBoard = JSON.parse(JSON.stringify(this.stage.board));
      tempBoard[this.piece1.row][this.piece1.col] = this.piece2.value;
      tempBoard[this.piece2.row][this.piece2.col] = this.piece1.value;

      const matchs1 = this.countMatches(
        tempBoard,
        this.piece1.row,
        this.piece1.col
      );
      const matchs2 = this.countMatches(
        tempBoard,
        this.piece2.row,
        this.piece2.col
      );

      const haveMatch = matchs1 >= match || matchs2 >= match;
      if (haveMatch) {
        setTimeout(this.switchPlaces, this.switchMoveDuration);
        return;
      }
      setTimeout(() => {
        this.rollbackPosition();
        this.piece1 = null;
        this.piece2 = null;
      }, this.switchMoveDuration);
    },
    countMatches(board, row, col) {
      let rowMatchs = 1;
      let colMatchs = 1;
      const value = board[row][col];

      for (let i = col - 1; i >= 0; i--) {
        if (value === board[row][i]) {
          rowMatchs++;
        } else {
          i = -1;
        }
      }
      for (let i = col + 1; i < board[0].length; i++) {
        if (value === board[row][i]) {
          rowMatchs++;
        } else {
          i = board[0].length + 1;
        }
      }

      for (let i = row - 1; i >= 0; i--) {
        if (value === board[i][col]) {
          colMatchs++;
        } else {
          i = -1;
        }
      }
      for (let i = row + 1; i < board.length; i++) {
        if (value === board[i][col]) {
          colMatchs++;
        } else {
          i = board.length + 1;
        }
      }

      return rowMatchs > colMatchs ? rowMatchs : colMatchs;
    },
    rollbackPosition() {
      this.moveUp = null;
      this.moveDown = null;
      this.moveLeft = null;
      this.moveRight = null;
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
