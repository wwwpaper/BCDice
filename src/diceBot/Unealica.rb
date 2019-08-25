# -*- coding: utf-8 -*-

class Unealica < DiceBot
  # ダイスボットで使用するコマンドを配列で列挙する
  setPrefixes(['\d*UN[@\d]*.*'])

  def initialize
    super

    # @sendMode = 2 #(0=結果のみ,1=0+式,2=1+ダイス個別)
    # @sortType = 2;      #ソート設定(1 = 足し算ダイスでソート有, 2 = バラバラロール（Bコマンド）でソート有, 3 = １と２両方ソート有）
    # @sameDiceRerollCount = 0;     #ゾロ目で振り足し(0=無し, 1=全部同じ目, 2=ダイスのうち2個以上同じ目)
    # @sameDiceRerollType = 0;   #ゾロ目で振り足しのロール種別(0=判定のみ, 1=ダメージのみ, 2=両方)
    # @d66Type = 1;        #d66の差し替え
    # @isPrintMaxDice = false;      #最大値表示
    # @upplerRollThreshold = 0;      #上方無限
    # @unlimitedRollDiceType = 0;    #無限ロールのダイス
    # @rerollNumber = 0;      #振り足しする条件
    # @defaultSuccessTarget = "";      #目標値が空欄の時の目標値
    # @rerollLimitCount = 0;    #振り足し回数上限
    # @fractionType = "roundUp";     #端数の処理 ("omit"=切り捨て, "roundUp"=切り上げ, "roundOff"=四捨五入)
  end

  def gameName
    'unealica'
  end

  def gameType
    "Unealica"
  end

  def getHelpMessage
    return <<MESSAGETEXT
ヘルプメッセージ
行為判定ロール（nUN）
  n個のサイコロで行為判定ロール。ロールを成功値として表示。nを省略すると3UK扱い。
  例）5UN ：サイコロ5個で行為判定
  例）UN  ：サイコロ2個で行為判定
MESSAGETEXT
  end

  def isGetOriginalMessage
    true
  end

#ダイスロールコマンド。nUN
  def rollDiceCommand(command)
    debug('rollDiceCommand command', command)

    result = ''

    case command
    when /(\d+)?UN(\@?(\d))?(>=(\d+))?/i
      base = ($1 || 2).to_i
      crit = $3.to_i
      diff = $5.to_i
      result= checkRoll(base, crit, diff)
    end

    return nil if result.empty?

    return "#{command} ＞ #{result}"
  end

  def checkRoll(base, crit, diff = 0)
    result = ''

    base = getValue(base)
    crit = getValue(crit)

    return result if( base < 1 )

    crit = 6 if( crit > 6 )

    result += "(#{base}d6)"

    _, diceText = roll(base, 6)

    diceList = diceText.split(/,/).collect{|i|i.to_i}.sort

    result += " ＞ "
    result += getRollResultString(diceList, crit, diff)
    result += " [#{diceList.join(',')}]"

    return result
  end

  def getRollResultString(diceList, crit, diff)

    success, achieve, successDice = getSuccessInfo(diceList, crit, diff)

    result = ""

    if( success )
      result += "達成値:#{achieve}(成功数:#{successDice})"
      if( diff != 0 )
        diffSuccess = (achieve >= diff)
        if( diffSuccess )
          result += " ＞ 成功"
        else
          result += " ＞ 失敗"
        end
      end

    else
      result += "失敗"
    end

    return result
  end

  def getSuccessInfo(diceList, crit, diff)
    debug("checkSuccess diceList, crit", diceList, crit)


    achieve = 0
    successDice = 0
    base = diceList.count
    critBase = base
    fambleCount = 0

    for i in diceList

      if i == 6
        achieve += 2
        successDice += 1
      elsif i == 5
        achieve += 1
        if crit
           achieve += 1
        end
        successDice += 1
      elsif i == 4
        achieve += 1
        successDice += 1
      elsif i == 3
#        achieve += 1
#        successDice += 1
      elsif i == 2
#        crit -= 1
      elsif i == 1
        fambleCount += 1
      end
    end

    if fambleCount > achieve
       achieve = 0
    end

    if achieve >= critBase
       achieve += base
    end

    if(achieve <= 0)
      # 失敗：ファンブル
      return false, 0, 0
    end

    # 成功：1成功以上
    return true, achieve, successDice
  end

  # ゲーム別成功度判定(2D6)
  def check_2D6(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)
    ''
  end

  # ゲーム別成功度判定(nD6)
  def check_nD6(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)
    ''
  end

  # ゲーム別成功度判定(nD10)
  def check_nD10(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)
    ''
  end

  # ゲーム別成功度判定(1d100)
  def check_1D100(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)
    ''
  end

  # ゲーム別成功度判定(1d20)
  def check_1D20(total_n, dice_n, signOfInequality, diff, dice_cnt, dice_max, n1, n_max)
    ''
  end

  def getValue(number)
    return 0 if( number > 100 )
    return number
  end

  #以下のメソッドはテーブルの参照用に便利
  #get_table_by_2d6(table)
  #get_table_by_1d6(table)
  #get_table_by_nD6(table, 1)
  #get_table_by_nD6(table, count)
  #get_table_by_1d3(table)
  #get_table_by_number(index, table)
  #get_table_by_d66(table)

  #getDiceList を呼び出すとロース結果のダイス目の配列が手に入ります。
end
