use godot::prelude::*;

mod entity;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}