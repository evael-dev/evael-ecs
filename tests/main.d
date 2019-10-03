import unit_threaded;

int main(string[] args)
{
    return args.runTests!(
        "tests.entity",
        "tests.component_pool",
        "tests.component_counter",
        "tests.event_counter",
        "tests.event_manager",
        "tests.system_manager",
        "tests.components_filter",
        "tests.system",
        "tests.entity_manager",
        "tests.world"
    );
}
