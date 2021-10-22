trigger PresupuestoTrigger on Quote (before insert, before update, after update) {
    TriggerDispatcher.run(new PresupuestoTriggerHandler(), 'PresupuestoTrigger');
}