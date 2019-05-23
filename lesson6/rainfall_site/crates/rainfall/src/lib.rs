#[macro_use]
extern crate helix;

ruby! {
    class Rainfall {
        

        def compute_volume(heights: Vec<u64>, iteration_count: u64) -> u64 {
            for _ in 0..iteration_count {
                compute_volume_internal(&heights);
            }
            0
        }

        
    }
}

pub fn compute_volume_internal(heights: &[u64]) -> u64 {
    assert!(!heights.is_empty(), "empty heights");

    let mut total = 0;
    for (i, height) in heights.iter().enumerate() {
        if i == 0 || i == heights.len() - 1 {
            continue;
        }
        let left_heights = &heights[..i];
        let right_heights = &heights[i..];
        let side_heights = [
            left_heights.iter().max().unwrap(), // &u8
            right_heights.iter().max().unwrap(),
        ];
        let wall_height = **side_heights.iter().min().unwrap();
        let water_height = wall_height.saturating_sub(*height);
        total += u64::from(water_height);
    }
    total
}
