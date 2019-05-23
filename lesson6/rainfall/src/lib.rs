use failure::{ensure, Fallible};

pub fn compute_volume(heights: &[u8]) -> Fallible<u64> {
    ensure!(!heights.is_empty(), "empty heights");

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
    Ok(total)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let heights = vec![3, 0, 0, 2, 4];
        match compute_volume(&heights) {
            Ok(v) => assert_eq!(v, 7),
            Err(_e) => {}
        }
    }
}
