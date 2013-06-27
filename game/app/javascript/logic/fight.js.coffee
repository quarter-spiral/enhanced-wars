Module = require('Module')
radio = require('radio')

exports class Fight extends Module
  @include lazy: -> require('EventedObject')


  constructor: (options) ->
    @set(options)

    attacker = @get('attacker')
    enemy = @get('enemy')

    @attack(attacker, enemy)
    @attack(enemy, attacker) if enemy.isAlive() and enemy.canReturnFire() and enemy.canAttack(attacker)
    player = attacker.player()
    player.deductAp(attacker.specs().costs.fire)
    player.scorePoints(player.get('game').ruleSet.rewards.attack) unless player.get('fired')
    player.set(fired: true)

  attack: (attacker, enemy) =>
    Bullet = require('Bullet')

    for bulletType in attacker.specs().bullets(enemy)
      bullet = new Bullet(game: attacker.game(), type: bulletType)
      enemy.set(hp: enemy.get('hp') - bullet.damage) if bullet.fireAt(enemy)
      radio('ew/game/attack').broadcast(attacker: attacker, enemy: enemy, bullet: bullet)

    if !enemy.isAlive()
      enemy.die()
      radio('ew/game/kill').broadcast(attacker: attacker, enemy: enemy, bullet: bullet)