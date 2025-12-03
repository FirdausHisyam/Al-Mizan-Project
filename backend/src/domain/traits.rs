pub trait Attributable {
    fn source(&self) -> String;
}

pub trait DigitalProvenance {
    fn digitized_by(&self) -> String;
    fn signature(&self) -> String;
}
