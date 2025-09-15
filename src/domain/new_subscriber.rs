use crate::domain::{SubscriberEmail, SubscriberName};

pub struct NewSubcriber {
    pub email: SubscriberEmail,
    pub name: SubscriberName,
}
