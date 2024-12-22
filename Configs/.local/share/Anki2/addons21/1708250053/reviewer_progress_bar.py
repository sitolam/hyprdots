# -*- coding: utf-8 -*-
"""
Anki Add-on: Progress Bar

Shows progress in the Reviewer in terms of passed cards per session.

Copyright:  (c) Unknown author (nest0r/Ja-Dark?) 2017
            (c) SebastienGllmt 2017 <https://github.com/SebastienGllmt/>
            (c) liuzikai 2018-2020 <https://github.com/liuzikai>
            (c) Glutanimate 2017-2018 <https://glutanimate.com/>
            (c) BluMist 2022 <https://github.com/BluMist>
            (c) carlos1172 2023 <https://github.com/carlos1172>
            (c) Shigeyuki 2024 <https://github.com/shigeyukey>
License: GNU AGPLv3 or later <https://www.gnu.org/licenses/agpl.html>
"""

# Do not modify the following lines
from __future__ import unicode_literals
from typing import Optional

from anki.hooks import addHook, wrap
from aqt.utils import showInfo

from aqt.qt import *
from aqt import mw
from typing import Dict

__version__ = '2.0.1'

############## USER CONFIGURATION START ##############

# CARD TALLY CALCULATION

# Which queues to include in the progress calculation (all True by default)
# 進行の計算に含めるｷｭｰ（ﾃﾞﾌｫﾙﾄではすべてTrue）
includeNew = True
includeRev = True
includeLrn = True

# Only include new cards once reviews are exhausted.
# ﾚﾋﾞｭｰが尽きた後にのみ､新しいｶｰﾄﾞを含めるようにします｡
includeNewAfterRevs = True

# Calculation weights

#   Setting proper weights will make the progress bar goes smoothly and reasonably.
#   For example, if all weight are 1, and you set 2 steps for a new card in your desk config, you will convey
#   one 'new' into two 'learning' card if you press 'again' at the first time, which will increase remaining
#   count and cause the bar to move backward.

# 重みの計算
#   適切な重みを設定することで､ﾌﾟﾛｸﾞﾚｽﾊﾞｰをｽﾑｰｽﾞかつ合理的に動かすことができます｡
#   たとえば､すべての重みが1で､ﾃﾞｽｸ構成で新しいｶｰﾄﾞに2つのｽﾃｯﾌﾟを設定した場合､最初に｢もう一度｣を押すと､
#   1つの｢新しい｣ｶｰﾄﾞを2つの｢学習｣ｶｰﾄﾞに変換してしまい､残りのｶｳﾝﾄが増え､ﾊﾞｰが後ろに動いてしまいます｡

#   In this case, it's probably a good idea to set newWeight to 2, and remaining count will be calculated as
#   new * 2 + learn + review. Now pressing 'again' will just make it stop going forward, but not backward. If
#   you press 'easy' at first, the progress will go twice as fast, which is still reasonable.

#   この場合､newWeightを2に設定するのが良いでしょう｡残りのｶｳﾝﾄは､new * 2 + learn + reviewで計算されます｡
#   これにより､最初に｢もう一度｣を押すと､前に進むのを止めるだけで､後ろに戻ることはありません｡最初に｢簡単｣を押すと､
#   進行が2倍速くなりますが､それでも合理的です｡

#   However, if you press 'good' followed by 'again', there will be another two learning card again, and the
#   progress still needs to go backward. It may not be a big deal, but if you want the progress never goes
#   backward strictly, enable forceForward below.
#   Weights should be integers. It's their relative sizes that matters, not absolute values.

#   ただし､｢良い｣と｢もう一度｣を押すと､再び2つの学習ｶｰﾄﾞが現れ､進行はまだ後ろに戻る必要があります｡
#   大きな問題ではないかもしれませんが､進行が厳密に後ろに戻らないようにしたい場合は､forceForwardを有効にしてください｡
#   重みは整数でなければなりません｡絶対値ではなく､相対的なｻｲｽﾞが重要です｡

#   Another example that make the progress goes unstably is 'bury related new cards to next day.' If you have
#   three new cards in a note, there will be 3 new cards at the beginning of your review, but another two will
#   disappear instantly after you learn one of them. However, all three cards will be regarded as 'completed,'
#   so your progress may go three times as fast.

#   別の進行が不安定になる例として､｢関連する新しいｶｰﾄﾞを次の日に埋める｣というものがあります｡
#   ﾉｰﾄに新しいｶｰﾄﾞが3つある場合､ﾚﾋﾞｭｰの最初に3つの新しいｶｰﾄﾞがありますが､1つを学習すると､
#   残りの2つがすぐに消えてしまいます｡ただし､すべての3つのｶｰﾄﾞが｢完了｣と見なされるため､進行は3倍速くなる場合があります｡


newWeight = 2
revWeight = 1
lrnWeight = 1



# If enabled, the progress will freeze if remaining count has to increase to prevent moving backward,
#   and wait until your correct answers 'make up' this additional part.
#   NOTE: This will not stop the progress from moving backward if you add cards or toggle suspended.

# 有効にすると､残りのｶｳﾝﾄが後ろに戻るのを防ぐために増加する必要がある場合に､進行が凍結され､
# 正しい回答が｢補填｣するまで待機します｡
# 注意：これは､ｶｰﾄﾞを追加したり､一時停止を切り替えたりしても､進行が後ろに戻るのを止めません｡
forceForward = False

# PROGRESS BAR APPEARANCE

def getConfig(arg, default=""):
    config = mw.addonManager.getConfig(__name__)
    if config:
        return config.get(arg, default)
    else:
        return default

showPercent = getConfig("showPercent", False) # 進行状況のﾃｷｽﾄとしてﾊﾟｰｾﾝﾃｰｼﾞを表示するかどうか｡
showNumber = getConfig("showNumber", False) # 進行状況のﾃｷｽﾄを分数として表示するかどうか｡

qtxt = getConfig("textColor", "aliceblue")  # ﾊﾟｰｾﾝﾃｰｼﾞの色（ﾃｷｽﾄが表示されている場合）｡
qbg = getConfig("backgroundColor", "rgba(0, 0, 0, 0)")  # 進行ﾊﾞｰの背景色｡
qfg = getConfig("foregroundColor", "#3399cc") # 進行ﾊﾞｰの前景色｡
qbr = getConfig("borderRadius", 0)  # ﾎﾞｰﾀﾞｰ半径（角を丸める場合は> 0）｡


# optionally restricts progress bar width
maxWidth = getConfig("maxWidth", "5px")  # (e.g. "5px". default: "")

scrollingBarWhenEditing = True  #再開を待っているときに進行状況ﾊﾞｰを｢ｽｸﾛｰﾙ｣させます｡

orientationHV = Qt.Orientation.Horizontal  # ﾊﾞｰを水平方向 (左右) に表示します｡上部/下部のﾄﾞｯｸｴﾘｱと併用します｡
# orientationHV = Qt.Vertical # Show bar vertically (up and down). Use with right/left dockArea.

invertTF = False  # If set to True, inverts and goes from right to left or top to bottom.

dockArea = Qt.DockWidgetArea.TopDockWidgetArea  # Shows bar at the top. Use with horizontal orientation.
# dockArea = Qt.DockWidgetArea.BottomDockWidgetArea # Shows bar at the bottom. Use with horizontal orientation.
# dockArea = Qt.DockWidgetArea.RightDockWidgetArea # Shows bar at right. Use with vertical orientation.
# dockArea = Qt.DockWidgetArea.LeftDockWidgetArea # Shows bar at left. Use with vertical orientation.

pbStyle = ""  #空白の場合にのみ使用されるｽﾀｲﾙｼｰﾄ｡それ以外の場合は､QPalette + ﾃｰﾏ ｽﾀｲﾙを使用します｡
'''pbStyle options (insert a quoted word above):
    -- "plastique", "windowsxp", "windows", "windowsvista", "motif", "cde", "cleanlooks"
    -- "macintosh", "gtk", or "fusion" might also work
    -- "windowsvista" unfortunately ignores custom colors, due to animation?
    -- Some styles don't reset bar appearance fully on undo. An annoyance.
    -- Themes gallery: http://doc.qt.io/qt-4.8/gallery.html'''

'''pbStyleｵﾌﾟｼｮﾝ（上に引用符で囲まれた単語を挿入）:
    -- "plastique", "windowsxp", "windows", "windowsvista", "motif", "cde", "cleanlooks"
    -- "macintosh", "gtk", または "fusion" も動作する場合があります
    -- "windowsvista" はｱﾆﾒｰｼｮﾝのためｶｽﾀﾑ色を無視してしまいます｡残念ながら｡
    -- 一部のｽﾀｲﾙは取り消し操作時にﾊﾞｰの外観が完全にﾘｾｯﾄされないことがあります｡不便なことです｡
    -- ﾃｰﾏｷﾞｬﾗﾘｰ: http://doc.qt.io/qt-4.8/gallery.html
'''


def didConfigChange():
    didChange = False

    global showPercent
    global showNumber

    global qtxt
    global qbg
    global qfg
    global qbr

    global maxWidth

    if showPercent != getConfig("showPercent", False):
        showPercent = getConfig("showPercent", False)
        didChange = True

    if showNumber != getConfig("showNumber", False):
        showNumber = getConfig("showNumber", False)
        didChange = True

    if qtxt != getConfig("textColor", "aliceblue"):
        qtxt = getConfig("textColor", "aliceblue")
        didChange = True

    if qbg != getConfig("backgroundColor", "rgba(0, 0, 0, 0)"):
        qbg = getConfig("backgroundColor", "rgba(0, 0, 0, 0)")
        didChange = True

    if qfg != getConfig("foregroundColor", "#3399cc"):
        qfg = getConfig("foregroundColor", "#3399cc")
        didChange = True

    if qbr != getConfig("borderRadius", 0):
        qbr = getConfig("borderRadius", 0)
        didChange = True

    if maxWidth != getConfig("maxWidth", "5px"):
        maxWidth = getConfig("maxWidth", "5px")
        didChange = True

    if didChange:
        # showInfo("config changed")
        global palette
        global orientationHV
        global restrictSize

        # Defining palette in case needed for custom colors with themes.
        palette = QPalette()
        palette.setColor(QPalette.ColorRole.Base, QColor(qbg))
        palette.setColor(QPalette.ColorRole.Base, QColor(qfg))
        palette.setColor(QPalette.ColorRole.Base, QColor(qbg))
        palette.setColor(QPalette.ColorRole.Base, QColor(qtxt))
        palette.setColor(QPalette.ColorRole.Base, QColor(qbg))

        if maxWidth:
            if orientationHV == Qt.Orientation.Horizontal:
                restrictSize = "max-height: %s;" % maxWidth
            else:
                restrictSize = "max-width: %s;" % maxWidth
        else:
            restrictSize = ""
        
    return didChange

##############  USER CONFIGURATION END  ##############

# Set up variables

remainCount = {}  # {did: remaining count (weighted) of the deck}
doneCount  = {}  # {did: done count (weighted) of the deck}, calculated as total - remain when showing next question
totalCount = {}  # {did: max total count (weighted) that was seen}, calculated as remain + done after state change
# NOTE: did stands for 'deck id'
# For old API of deckDueList(), these counts don't include cards in children decks. For new deck_due_tree(), they do.


currDID: Optional[int] = None  # current deck id (None means at the deck browser)

nmStyleApplied = 0
nmUnavailable = 0
progressBar_2: Optional[QProgressBar] = None

pbdStyle = QStyleFactory.create("%s" % pbStyle)  # Don't touch.

# Defining palette in case needed for custom colors with themes.
palette = QPalette()
palette.setColor(QPalette.ColorRole.Base, QColor(qbg))
palette.setColor(QPalette.ColorRole.Highlight, QColor(qfg))
palette.setColor(QPalette.ColorRole.Button, QColor(qbg))
palette.setColor(QPalette.ColorRole.WindowText, QColor(qtxt))
palette.setColor(QPalette.ColorRole.Window, QColor(qbg))

if maxWidth:
    if orientationHV == Qt.Orientation.Horizontal:
        restrictSize = "max-height: %s;" % maxWidth
    else:
        restrictSize = "max-width: %s;" % maxWidth
else:
    restrictSize = ""

try:
    # ﾅｲﾄﾓｰﾄﾞがある場合は､このｱﾄﾞｵﾝとの競合を避けるために､煩わしいｾﾊﾟﾚｰﾀｰｽﾄﾘｯﾌﾟを削除します｡
    import Night_Mode # type:ignore

    Night_Mode.nm_css_menu \
        += Night_Mode.nm_css_menu \
           + '''
        QMainWindow::separator
    {
        width: 0px;
        height: 0px;
    }
    '''
except ImportError:
    nmUnavailable = 1


def initPB() -> None:
    """Initialize and set parameters for progress bar, adding it to the dock."""
    global progressBar_2
    if not progressBar_2:
        # 最初のｲﾝｽﾀﾝｽの場合のみﾌﾟﾛｸﾞﾚｽﾊﾞｰとﾄﾞｯｷﾝｸﾞを作成します
        progressBar_2 = QProgressBar()
        _dock(progressBar_2)
    progressBar_2.setTextVisible(showPercent or showNumber)
    progressBar_2.setInvertedAppearance(invertTF)
    progressBar_2.setOrientation(orientationHV)
    if pbdStyle is None:
        progressBar_2.setStyleSheet(
            '''
                QProgressBar
                {
                    text-align:center;
                    color:%s;
                    background-color: %s;
                    border-radius: %dpx;
                    %s
                }
                QProgressBar::chunk
                {
                    background-color: %s;
                    margin: 0px;
                    border-radius: %dpx;
                }
                ''' % (qtxt, qbg, qbr, restrictSize, qfg, qbr))
    else:
        progressBar_2.setStyle(pbdStyle)
        progressBar_2.setPalette(palette)

def _dock(pb: QProgressBar) -> QDockWidget:
    """Dock for the progress bar. Giving it a blank title bar,
        making sure to set focus back to the reviewer.
        進行状況ﾊﾞｰをﾄﾞｯｷﾝｸﾞします｡空白のﾀｲﾄﾙ ﾊﾞｰを表示します｡
        必ずﾚﾋﾞｭｰ担当者に焦点を戻すようにしてください｡"""
    dock = QDockWidget()
    tWidget = QWidget()
    # dock.setObjectName("pbDock")
    dock.setWidget(pb)
    dock.setTitleBarWidget(tWidget)

    # Note: if there is another widget already in this dock position, we have to add ourself to the list
    # 注: このﾄﾞｯｸ位置にすでに別のｳｨｼﾞｪｯﾄがある場合は自分自身をﾘｽﾄに追加する必要があります

    # first check existing widgets
    existing_widgets = [widget for widget in mw.findChildren(QDockWidget) if mw.dockWidgetArea(widget) == dockArea]

    # then add ourselves
    mw.addDockWidget(dockArea, dock)

    # stack with any existing widgets
    if len(existing_widgets) > 0:
        mw.setDockNestingEnabled(True)

        if dockArea == Qt.DockWidgetArea.TopDockWidgetArea or dockArea == Qt.DockWidgetArea.BottomDockWidgetArea:
            stack_method = Qt.Orientation.Vertical
        if dockArea == Qt.DockWidgetArea.LeftDockWidgetArea or dockArea == Qt.DockWidgetArea.RightDockWidgetArea:
            stack_method = Qt.Orientation.Horizontal
        mw.splitDockWidget(existing_widgets[0], dock, stack_method)


    if qbr > 0 or pbdStyle is not None:
        # Matches background for round corners.
        # Also handles background for themes' percentage text.
        # 丸い角の背景に一致します｡
        # ﾃｰﾏのﾊﾟｰｾﾝﾄﾃｷｽﾄの背景も処理します｡
        mw.setPalette(palette)
    mw.web.setFocus()
    return dock


def updatePB() -> None:
    """Update progress bar range and value with currDID, totalCount[] and doneCount[]
        \ncurrDID､totalCount[]､およびdoneCount[]を使用してﾌﾟﾛｸﾞﾚｽﾊﾞｰの範囲と値を更新します｡"""

    if currDID:  # in a specific deck
        pbMax = totalCount[currDID]
        pbValue = doneCount[currDID]
    else:  # at desk browser
        pbMax = pbValue = 0
        # Sum top-level decks
        for node in mw.col.sched.deck_due_tree().children:
            pbMax += totalCount[node.deck_id]
            pbValue += doneCount[node.deck_id]

    # showInfo("pbMax = %d, pbValue = %d" % (pbMax, pbValue))

    if pbMax == 0:  # 100%
        progressBar_2.setRange(0, 1)
        progressBar_2.setValue(1)
    else:
        progressBar_2.setRange(0, pbMax)
        progressBar_2.setValue(pbValue)

    if showNumber:
        if showPercent:
            percent = 100 if pbMax == 0 else int(100 * pbValue / pbMax)
            progressBar_2.setFormat("%d / %d (%d%%)" % (pbValue, pbMax, percent))
        else:
            progressBar_2.setFormat("%d / %d" % (pbValue, pbMax))
    nmApplyStyle()


def setScrollingPB() -> None:
    """Make progress bar in waiting style if the state is resetRequired (happened after editing cards.)
    \n状態がﾘｾｯﾄ必須の場合､進行状況ﾊﾞｰを待機ｽﾀｲﾙにします (ｶｰﾄﾞの編集後に発生します)"""
    progressBar_2.setRange(0, 0)
    if showNumber:
        progressBar_2.setFormat("Waiting...")
    nmApplyStyle()


def nmApplyStyle() -> None:
    """Checks whether Night_Mode is disabled:
        if so, we remove the separator here.
        \nNight_Mode が無効になっているかどうかを確認します｡
        その場合は､ここで区切り文字を削除します｡"""
    global nmStyleApplied
    if not nmUnavailable:
        nmStyleApplied = Night_Mode.nm_state_on
    if not nmStyleApplied:
        mw.setStyleSheet(
            '''
        QMainWindow::separator
    {
        width: 0px;
        height: 0px;
    }
    ''')


def calcProgress(rev: int, lrn: int, new: int) -> int:
    # ｽｹｼﾞｭｰﾙからの重みとｶｰﾄﾞ数を使用して進行状況を計算します｡
    ret = 0
    if includeRev:
        ret += rev * revWeight
    if includeLrn:
        ret += lrn * lrnWeight
    if includeNew or (includeNewAfterRevs and rev == 0):
        ret += new * newWeight
    return ret


def updateCountsForAllDecks(updateTotal: bool) -> None:

    """
    Update counts.
    ｶｳﾝﾄを更新します｡

    After adding, editing or deleting cards (afterStateChange hook), updateTotal should be set to True to update
    totalCount[] based on doneCount[] and remainCount[]. No card should have been answered before this hook is
    triggered, so the change in remainCount[] should be caused by editing collection and therefore goes into
    totalCount[].

    ｶｰﾄﾞを追加､編集､または削除した後（afterStateChangeﾌｯｸ）､
    totalCount []をdoneCount []とremainCount []に基づいて更新するために､
    updateTotalをTrueに設定する必要があります｡
    このﾌｯｸがﾄﾘｶﾞｰされる前に､ｶｰﾄﾞに回答されていないため､
    remainCount []の変更はｺﾚｸｼｮﾝの編集によって引き起こされ､totalCount []に入ります｡

    When the user answer a card (showQuestion hook), updateTotal should be set to False to update doneCount[] based on
    totalCount[] and remainCount[]. No change to collection should have been made before this hook is
    triggered, so the change in remainCount[] should be caused by answering cards and therefore goes into
    doneCount[].

    ﾕｰｻﾞｰがｶｰﾄﾞに回答すると（showQuestionﾌｯｸ）､
    updateTotalをFalseに設定して､totalCount []とremainCount []に基づいて
    doneCount []を更新する必要があります｡
    このﾌｯｸがﾄﾘｶﾞｰされる前に､ｺﾚｸｼｮﾝに変更が加えられていないため､
    remainCount []の変更はｶｰﾄﾞに回答することによって引き起こされ､doneCount []に入ります｡

    In the later case, remainCount[] may still increase based on the weights of New, Lrn and Rev cards (see comments
    of "Calculation weights" above), in which case totalCount[] may still get updated based on forceForward setting.

    後者の場合､New､Lrn､Revｶｰﾄﾞの重みに基づいてremainCount []が
    まだ増加する可能性があります（上記の｢計算重み｣のｺﾒﾝﾄを参照）､
    その場合､totalCount []はforceForward設定に基づいて更新される可能性があります｡

    :param updateTotal: True for afterStateChange hook, False for showQuestion hook

    :param updateTotal:afterStateChangeﾌｯｸの場合はTrue､showQuestionﾌｯｸの場合はFalse
    """


    for node in mw.col.sched.deck_due_tree().children:
        updateCountsForTree(node, updateTotal)


def updateCountsForTree(node, updateTotal: bool) -> None:
    did = node.deck_id
    remain = calcProgress(node.review_count, node.learn_count, node.new_count)

    updateCountsForDeck(did, remain, updateTotal)

    for child in node.children:
        updateCountsForTree(child, updateTotal)


def updateCountsForDeck(did: int, remain: int, updateTotal: bool):
    if did not in totalCount.keys():
        totalCount[did] = remainCount[did] = remain
        doneCount[did] = 0
    else:
        remainCount[did] = remain
        if updateTotal:
            totalCount[did] = doneCount[did] + remainCount[did]
        else:
            if remainCount[did] + doneCount[did] > totalCount[did]:
                # This may happen if you press 'again' followed by 'good' for a new card, as stated in comments
                # "Calculation weights,' or when you undo a card, making remaining count increases.
                # これは､ｺﾒﾝﾄで述べられているように､新しいｶｰﾄﾞに対して
                # 'again' に続いて 'good' を押すか､
                # ｶｰﾄﾞを元に戻して残りのｶｳﾝﾄが増加する場合に発生する可能性があります｡
                # ｢計算重み｣､またはｶｰﾄﾞを元に戻すときに発生します｡

                if forceForward:
                    # give up changing counts, until the remainCount decrease.
                    # remainCountが減少するまで､ｶｳﾝﾄの変更を諦めます｡
                    pass
                else:
                    totalCount[did] = doneCount[did] + remainCount[did]
            else:
                doneCount[did] = totalCount[did] - remainCount[did]


def afterStateChangeCallBack(state: str, oldState: str) -> None:
    global currDID

    if state == "resetRequired":
        if scrollingBarWhenEditing:
            setScrollingPB()
        return
    elif state == "deckBrowser":
        # initPB() has to be here, since objects are not prepared yet when the add-on is loaded.
        # ｱﾄﾞｵﾝのﾛｰﾄﾞ時にｵﾌﾞｼﾞｪｸﾄがまだ準備されていないため､initPB() がここに存在する必要があります｡
        if not progressBar_2 or didConfigChange():
            initPB()
            updateCountsForAllDecks(True)
        currDID = None
    elif state == "profileManager":
        # fix crash with multiple profiles
        # 複数のﾌﾟﾛﾌｧｲﾙによるｸﾗｯｼｭを修正
        return
    else:  # "overview" or "review"
        # showInfo("mw.col.decks.current()['id'])= %d" % mw.col.decks.current()['id'])
        currDID = mw.col.decks.current()['id']

    # showInfo("updateCountsForAllDecks(True), currDID = %d" % (currDID if currDID else 0))
    updateCountsForAllDecks(True)  # updateCountsForAllDecks() のｺﾒﾝﾄを参照
    updatePB()


def showQuestionCallBack() -> None:
    # showInfo("updateCountsForAllDecks(False), currDID = %d" % (currDID if currDID else 0))
    updateCountsForAllDecks(False)  # updateCountsForAllDecks() のｺﾒﾝﾄを参照
    updatePB()


addHook("afterStateChange", afterStateChangeCallBack)
addHook("showQuestion", showQuestionCallBack)

