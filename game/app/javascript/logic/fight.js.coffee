Module = require('Module')
radio = require('radio')

exports class Fight extends Module
  @include lazy: -> require('EventedObject')


  constructor: (options) ->
    @set(options)

    attacker = @get('attacker')
    enemy = @get('enemy')

    apCost = attacker.specs().costs.fire
    player = attacker.player()
    game = player.get('game')

    actionOptions =
      unitsBefore: [
        {position: attacker.position(), dump: attacker.dump()}
        {position: enemy.position(), dump: enemy.dump()}
      ]
      streakBefore: game.dumpStreaks()
      apCost: apCost,
      pointsBefore: game.dumpPoints()
      playersFiredBefore: (tPlayer.get('fired') for tPlayer in game.players)

    @attack(attacker, enemy)
    @attack(enemy, attacker) if enemy.isAlive() and enemy.canReturnFire() and enemy.canAttack(attacker)

    attacker.set(fired: true)
    attacker.set(mp: 0) unless attacker.specs().movesAndFires

    player.deductAp(apCost)
    unless player.get('fired')
      player.scorePoints(game.ruleSet.rewards.attack)
      radio('ew/game/streak').broadcast(streakValue: 0)

    player.set(fired: true)

    actionOptions.unitsAfter = [
      {position: attacker.position(), dump: attacker.dump()}
      {position: enemy.position(), dump: enemy.dump()}
    ]
    actionOptions.streakAfter = game.dumpStreaks()
    actionOptions.pointsAfter = game.dumpPoints()
    actionOptions.playersFiredAfter = (tPlayer.get('fired') for tPlayer in game.players)
    FightAction = require('FightAction')
    game.addAction new FightAction(actionOptions)


  attack: (attacker, enemy) =>
    Bullet = require('Bullet')

    for bulletType in attacker.specs().bullets(enemy)
      bullet = new Bullet(game: attacker.game(), type: bulletType)
      enemy.set(hp: enemy.get('hp') - bullet.damage) if bullet.fireAt(enemy)
      radio('ew/game/attack').broadcast(attacker: attacker, enemy: enemy, bullet: bullet)

    if !enemy.isAlive()
      enemy.die()
      radio('ew/game/kill').broadcast(attacker: attacker, enemy: enemy, bullet: bullet)